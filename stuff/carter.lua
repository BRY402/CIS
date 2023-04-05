local HttpService = game:GetService("HttpService")
local lib = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua",true))()
local bots = {}
local carter = {new = function(api_key, scene, version)
	local storage = {
		key = "",
		scene = "Normal",
		CanChat = true,
		ids = {}
	}
	local ChatterEvent = lib.Utilities.newEvent("ChatterAdded", "AddChatter")
	local BotChatted = lib.Utilities.newEvent("Chatted")
	local bot = {
		ChatterAdded = ChatterEvent.ChatterAdded,
		Chatted = BotChatted.Chatted
	}
	function bot:Exit()
		storage.CanChat = false
	end
	local Versions = {
		V0 = function()
			warn("i dont really recommend using v0 since they added v1 but its up to you")
			storage.url = "https://api.carterapi.com/v0/chat"
			if scene then
				storage.scene = tostring(scene)
			end
			function bot:Send(msg, player)
				assert(storage.CanChat,"Bot#"..tostring(table.find(bots, bot)).." is disabled")
				local id = player and player.UserId or 0
				if player and not table.find(storage.ids, id) then
					table.insert(storage.ids,id)
					ChatterEvent:AddChatter(player)
				end
				local response = HttpService:RequestAsync({Url = storage.url,
					Method = "POST",
					Headers = {["Content-Type"] = "application/json"},
					Body = HttpService:JSONEncode({
						api_key = storage.key,
						query = msg,
						uuid = id,
						scene = storage.scene
					})
				})
				assert(response.Success,"Response fail: "..response.StatusCode..", "..response.StatusMessage)
				local reply = HttpService:JSONDecode(response.Body)
					local outputData = {
						Player = player,
						Time_Taken = reply.time_taken,
						Credits_Used = reply.credits_used
					}
			local outputText = reply.output.text
				BotChatted:Fire(outputText, outputData)
				return outputText, outputData
			end
			function bot:SetScene(scene)
				assert(scene, "Missing scene argument for SetScene")
				storage.scene = tostring(scene)
			end
		end,
		V1 = function()
			storage.url = "https://api.carterlabs.ai/chat"
			function bot:Send(msg, player)
				assert(storage.CanChat,"Bot#"..tostring(table.find(bots, bot)).." is disabled")
				local id = player and player.UserId or 0
				if player and not table.find(storage.ids, id) then
					table.insert(storage.ids,id)
					ChatterEvent:AddChatter(player)
				end
				local response = HttpService:RequestAsync({Url = storage.url,
					Method = "POST",
					Headers = {["Content-Type"] = "application/json"},
					Body = HttpService:JSONEncode({
						key = storage.key,
						text = msg,
						playerId = id,
					})
				})
				assert(response.Success,"Response fail: "..response.StatusCode..", "..response.StatusMessage)
				local reply = HttpService:JSONDecode(response.Body)
					local outputData = {
						Player = player,
						Time_Taken = reply.time_taken,
						Credits_Used = reply.credits_used
					}
				local outputText = reply.output.text
				BotChatted:Fire(outputText, outputData)
				return outputText, outputData
			end
		end
	}
	local botVersion = Versions[version]
	assert(botVersion, "Invalid version")
	storage.key = tostring(api_key)
	bot.Version = version
	botVersion()
	table.insert(bots, bot)
	return bot
end}
return carter
