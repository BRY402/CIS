NLS([==[print([[-- Chat commands:
-speed
-fix]])
local uis = game:GetService("UserInputService")
local posp = Instance.new("Part",script)
posp.Size = Vector3.new(1,1,1)
posp.CanCollide = false
posp.Anchored = true
posp.Transparency = .75
local fly = false
local speed = 2
uis.InputBegan:Connect(function(inp,c)
	if inp.KeyCode == Enum.KeyCode.F and not c then
		fly = not fly
		if fly then
			local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
			if fly and hrp then
				table.foreach(owner.Character:GetDescendants(),function(i,v)
					if v:IsA("Part") then
						v.CustomPhysicalProperties = PhysicalProperties.new(math.huge,math.huge,0,math.huge,0)
					end
				end)
				posp.Position = hrp.Position
				vf = Instance.new("VectorForce",hrp)
				local at = Instance.new("Attachment",hrp)
				vf.Attachment0 = at
				vf.RelativeTo = Enum.ActuatorRelativeTo.World
				vf.ApplyAtCenterOfMass = true
				vf.Force = Vector3.new(0,workspace.Gravity * hrp.AssemblyMass,0)
			end
		else
			if vf then
				vf:Destroy()
				vf.Attachment0:Destroy()
				table.foreach(owner.Character:GetDescendants(),function(i,v)
					if v:IsA("Part") then
						v.CustomPhysicalProperties = nil
					end
				end)
			end
		end
	else
		local cam = workspace.CurrentCamera
		local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
		if hrp and cam then
			if inp.KeyCode == Enum.KeyCode.W and not c then
				posp.Position = posp.Position + cam.CFrame.lookVector * speed
				hw = 1
			elseif inp.KeyCode == Enum.KeyCode.A and not c then
				posp.Position = posp.Position + cam.CFrame.rightVector * -speed
				ha = 1
			elseif inp.KeyCode == Enum.KeyCode.S and not c then
				posp.Position = posp.Position + cam.CFrame.lookVector * -speed
				hs = 1
			elseif inp.KeyCode == Enum.KeyCode.D and not c then
				posp.Position = posp.Position + cam.CFrame.rightVector * speed
				hd = 1
			elseif inp.KeyCode == Enum.KeyCode.Q and not c then
				posp.Position = posp.Position + cam.CFrame.upVector * -speed
				hq = 1
			elseif inp.KeyCode == Enum.KeyCode.E and not c then
				posp.Position = posp.Position + cam.CFrame.upVector * speed
				he = 1
			end
		end
	end
end)
uis.InputEnded:Connect(function(inp,c)
	local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		if inp.KeyCode == Enum.KeyCode.W and not c then
			hw = 0
		elseif inp.KeyCode == Enum.KeyCode.A and not c then
			ha = 0
		elseif inp.KeyCode == Enum.KeyCode.S and not c then
			hs = 0
		elseif inp.KeyCode == Enum.KeyCode.D and not c then
			hd = 0
		elseif inp.KeyCode == Enum.KeyCode.Q and not c then
			hq = 0
		elseif inp.KeyCode == Enum.KeyCode.E and not c then
			he = 0
		end
	end
end)
local cn = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
	local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
	if fly and hrp then
		local cf = workspace.CurrentCamera.CFrame
		hrp.CFrame = CFrame.new(hrp.Position) * cf.Rotation
	end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	cn:Disconnect()
	cn = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
		if fly and hrp then
			local cf = workspace.CurrentCamera.CFrame
			hrp.CFrame = CFrame.new(hrp.Position) * cf.Rotation
		end
	end)
end)
owner.Chatted:Connect(function(msg)
local smsg = string.split(msg," ")
	if smsg[1] == "/e" or smsg[1] == "/emote" then
		table.remove(smsg,1)
	end
	if smsg[1] == "-speed" then
		if smsg[2] then
			local fsp = tonumber(smsg[2]) or speed
			speed = fsp
		end
	elseif smsg[1] == "-fix" then
		local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
		if vf and hrp then
			vf.Force = Vector3.new(0,workspace.Gravity * hrp.AssemblyMass,0)
		else
			warn("Unable to recalibrate weight detection")
		end
	end
end)
owner.CharacterAdded:Connect(function(char)
	if fly then
		local hrp = char:WaitForChild("HumanoidRootPart")
		if hrp then
			table.foreach(owner.Character:GetDescendants(),function(i,v)
				if v:IsA("Part") then
					v.CustomPhysicalProperties = PhysicalProperties.new(math.huge,math.huge,0,math.huge,0)
				end
			end)
			vf = Instance.new("VectorForce",hrp)
			local at = Instance.new("Attachment",hrp)
			vf.Attachment0 = at
			vf.RelativeTo = Enum.ActuatorRelativeTo.World
			vf.ApplyAtCenterOfMass = true
			vf.Force = Vector3.new(0,workspace.Gravity * hrp.AssemblyMass,0)
		end
	end
end)
while task.wait() do
	local hum = owner.Character:FindFirstChildOfClass("Humanoid")
	local hrp = owner.Character:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if hum then
		if fly then
			hum.Sit = false
		end
		hum.PlatformStand = fly
	end
	if fly and hrp and cam and not hum.Sit then
		hrp.AssemblyLinearVelocity = Vector3.new()
		hrp.AssemblyAngularVelocity = Vector3.new()
		hrp.CFrame = CFrame.new(posp.Position) * hrp.CFrame.Rotation
	end
	if hw == 1 then
		posp.Position = posp.Position + cam.CFrame.lookVector * speed
	end
	if ha == 1 then
		posp.Position = posp.Position + cam.CFrame.rightVector * -speed
	end
	if hs == 1 then
		posp.Position = posp.Position + cam.CFrame.lookVector * -speed
	end
	if hd == 1 then
		posp.Position = posp.Position + cam.CFrame.rightVector * speed
	end
	if hq == 1 then
		posp.Position = posp.Position + cam.CFrame.upVector * -speed
	end
	if he == 1 then
		posp.Position = posp.Position + cam.CFrame.upVector * speed
	end
end]==],owner.PlayerGui)
