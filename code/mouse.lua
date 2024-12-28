--[[
**Mobile mouse support, adds most functionalities that desktop has
**This is meant to be used inside script builders (ROBLOX experiences that allow sandboxed code execution)
because there is no real use for this outside of them
**Localscript only, the mouse is shared through localscripts by the shared table (can be accessed as shared.mouse)
]]
-- Services
local GuiService = game:FindService("GuiService")
local UserInputService = game:FindService("UserInputService")
local RunService = game:FindService('RunService')

-- Mouse functionality
script.Name = 'MouseHandler'
local bindableFunction = Instance.new('BindableFunction', script)
local camera = workspace.CurrentCamera
local ScreenSize = camera.ViewportSize
local function newEvent()
    local bindableEvent = Instance.new('BindableEvent', script)
    return bindableEvent
end
local function getplatform()
    if (GuiService:IsTenFootInterface()) then
        return "Console"
    elseif (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
        return "Mobile"
    else
        return "Desktop"
    end
end
local Button1Down = newEvent()
local Button1Up = newEvent()
local Button2Down = newEvent()
local Button2Up = newEvent()
local Idle = newEvent()
local Move = newEvent()
local WheelBackward = newEvent()
local WheelForward = newEvent()
local function GetMouse()
    local platform = getplatform()
    if platform == 'Console' then
      error('Not supported')
    elseif platform == 'Desktop' then
      return owner:GetMouse()
    end
    return {
      Hit = CFrame.identity,
      Icon = '',
      Origin = CFrame.identity,
      Target = nil,
      TargetFilter = nil,
      TargetSurface = Enum.NormalId.Top,
      UnitRay = nil,
      ViewSizeX = ScreenSize.X,
      ViewSizeY = ScreenSize.Y,
      X = 0,
      Y = 0,
      Button1Down = Button1Down.Event,
      Button1Up = Button1Up.Event,
      Button2Down = Button2Down.Event,
      Button2Up = Button2Up.Event,
      Idle = Idle.Event,
      Move = Move.Event,
      WheelBackward = WheelBackward.Event,
      WheelForward = WheelForward.Event
    }
end
local GetNornalFromFace
local function NormalToFace(normalVector, part)

    local TOLERANCE_VALUE = 1 - 0.001
    local allFaceNormalIds = {
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Bottom,
        Enum.NormalId.Top,
        Enum.NormalId.Left,
        Enum.NormalId.Right
    }    

    for _, normalId in pairs( allFaceNormalIds ) do
        -- If the two vectors are almost parallel,
        if GetNormalFromFace(part, normalId):Dot(normalVector) > TOLERANCE_VALUE then
            return normalId -- We found it!
        end
    end
    
    return nil -- None found within tolerance.

end
function GetNormalFromFace(part, normalId)
    return part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(normalId))
end
local mouse = GetMouse()
bindableFunction.OnInvoke = function(i)
    return mouse[i]
end
shared.mouse = setmetatable({}, {__index = function(_, i) return bindableFunction:Invoke(i) end})
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
local mouseInfo = {longPress = false, updating = false}
local function updateMouse(position)
    mouseInfo.updating = true
    mouse.X = position.X
    mouse.Y = position.Y
    local camera = workspace.CurrentCamera
    local cameracframe = camera and camera.CFrame or CFrame.identity
    local ray = camera:ScreenPointToRay(mouse.X, mouse.Y, (2^53) - 1)
    mouse.UnitRay = ray
    params.FilterDescendantsInstances = {mouse.TargetFilter}
    local hit = workspace:Raycast(cameracframe.Position + ray.Direction, ray.Origin, params) -- i think chatgpt could do a lot better than this shit
    if not hit then
      mouse.Origin = CFrame.lookAt(cameracframe.Position + ray.Direction, ray.Origin)
      mouse.Target = nil
      mouse.TargetSurface = nil
      mouse.Hit = CFrame.new(ray.Origin) * mouse.Origin.Rotation
      return
    end
    mouse.Origin = CFrame.lookAt(cameracframe.Position + ray.Direction, hit.Position)
    mouse.Target = hit.Instance
    mouse.TargetSurface = NormalToFace(hit.Normal, hit.Instance)
    mouse.Hit = CFrame.new(hit.Position) * mouse.Origin.Rotation
    task.wait()
    mouseInfo.updating = false
end
UserInputService.TouchStarted:Connect(function(input, processed)
    mouseInfo.longPress = false
    updateMouse(input.Position)
    Button1Down:Fire()
end)
UserInputService.TouchEnded:Connect(function(input, processed)
      updateMouse(input.Position)
      if mouseInfo.longPress then
          Button2Up:Fire()
          return
      end
      Button1Up:Fire()
end)
UserInputService.TouchLongPress:Connect(function(positions, state, processed)
    mouseInfo.longPress = true
    updateMouse(positions[1])
    Button2Down:Fire()
end)
UserInputService.TouchMoved:Connect(function(input, processed)
    updateMouse(input.Position)
    Move:Fire()
end)
RunService.PostSimulation:Connect(function()
    if not mouseInfo.updating then
      Idle:Fire()
    end
end)
