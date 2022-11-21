local ts = game:GetService("TweenService")
local Tracker = {Tracks = {}}
local function tts(t,n,iit)
	if iit then
		n = "["..tonumber(n).."]" or "[\""..tostring(n).."\"]"
	end
	local str = n.." = {\n"
	for i,v in pairs(t) do
		if typeof(v) == "table" then
			str = str..tts(v,i,true)
		else
			str = i ~= #t and str..tostring(v)..",\n" or str..tostring(v)
		end
	end
	return str.."\n}"
end
Tracker.AddTrack = function(trackname: string, speed: number, decay: number)
	Tracker.Tracks[trackname] = {Speed = speed,
	DecayTime = decay,
	Actions = {}}
end)
Tracker.AddCFrame = function(trackname: string, target: Instance, cf: CFrame, speed: number)
	local track = Tracker.Tracks[trackname]
	assert(track,"Invalid track name")
	track.Actions["Action"..#track.Actions] = {CFrame = cf,
	Target = target,
	Speed = speed * track.Speed}
end
Tracker.GetTrackData = function(name: string)
	if name then
		local track = Tracker.Tracks[name]
		assert(track,"Invalid track name")
		return tts(Tracker.Tracks[name],name,false)
	else
		local gottracks = {}
		for i,v in pairs(Tracker.Tracks) do
			table.insert(gottracks,i)
			task.wait()
		end
		return tts(gottracks,"Tracks",false)
	end
end)
Tracker.PlayTrack = function(name)
	local track = Tracker.Tracks[name]
	assert(track,"Invalid track name")
	table.foreach(track.Actions,function(i,v)
		local info = TweenInfo.new(1 / v.Speed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
		if v.Target:IsA("BasePart") then
			doaction = {CFrame = v.Target.CFrame * v.CFrame}
		elseif v:IsA("Weld") or v:IsA("Motor6D") then
			doaction = {C0 = v.CFrame}
		end
		ts:Create(v.Part,info,doaction):Play()
	end)
end
return Tracker
