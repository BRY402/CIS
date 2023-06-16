local HttpService = game:GetService("HttpService")
local sandboxed_env = getfenv()
local tostring
local currentTextbox
local env = {}
local terminal
local io
local imports = {
	tpscript = "https://raw.githubusercontent.com/headsmasher8557/tpscript/main/init.lua",
	comradio = "https://gist.github.com/BRY402/fc0952ccabd77cf77a7183517f4507ac/raw",
	encrypt = "https://raw.githubusercontent.com/Wapplee/Lua-Sandbox-Scripts/main/Modules/Encode-Decode.lua",
	html = "https://gist.github.com/BRY402/212bd48e3778968791e445503facea97/raw"
}
env.imports = imports
local function import(name)
	local url = imports[name]
	if url then
		local func, fail = loadstring(HttpService:GetAsync(url), name)
		assert(func, "Import failure: "..(fail or ""))
		local returned = table.pack(setfenv(func, setmetatable({}, {
			__index = function(self, index)
				return env[index] or getfenv()[index]
			end,
			__newindex = rawset
		}))())
		returned.n = nil
		return table.unpack(returned)
	else
		local func, fail = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/"..name..".lua", true), name)
		assert(func, "Import failure: "..(fail or ""))
		local returned = table.pack(setfenv(func, setmetatable({}, {
			__index = function(self, index)
				return env[index] or getfenv()[index]
			end,
			__newindex = rawset
		}))())
		returned.n = nil
		return table.unpack(returned)
	end
end
local lib = import("lib")
local tpscript = import("tpscript")
local html = import("html")
local inputHandler = {
	expectingInput = false,
	secretInput = false,
	inputEvent = lib.Utilities.newEvent("OnInput")
}
env.threadMng = {
	Threads = {},
	kill = function()
		for i, v in pairs(env.threadMng.Threads) do
			if coroutine.status(v) ~= "dead" then
				if v ~= coroutine.running() then
					task.cancel(v)
					table.remove(env.threadMng.Threads, i)
					task.wait()
				end
			else
				table.remove(env.threadMng.Threads, i)
				task.wait()
			end
		end
		table.remove(env.threadMng.Threads,table.find(env.threadMng.Threads,coroutine.running()))
		coroutine.yield()
	end
}
env.tostring = tostring
env.import = import
io = {
	read = function(secret, delay_)
		inputHandler.expectingInput = true
		inputHandler.secretInput = secret and true or false
		local args = lib.Utilities.Pack(inputHandler.inputEvent.OnInput:Wait(delay_, true))
		inputHandler.expectingInput = false
		inputHandler.secretInput = false
		assert(#args > 0, "io.read failure, response took too long or input is empty.")
		return table.unpack(args)
	end,
	write = function(str)
		currentTextbox.Text = currentTextbox.Text..str
	end,
	fire = function(...)
		inputHandler.inputEvent:Fire(...)
	end
}
env.io = io
local files = {}
local extensions = {
	txt = function(file)
		return file.Source
	end,
	lua = function(file)
		return terminal.exec(file.Source, "file '"..file.Name.."'")
	end,
	tps = function(file)
		return tpscript.loadstring(file.Source)
	end,
	json = function(file)
		return HttpService:JSONDecode(file.Source)
	end
}
extensions.luau = extensions.lua
extensions.tpscript = extensions.tps
local file = {
	Create = function(self, file_name, source)
		local file_name = tostring(file_name)
		local source = tostring(source)
		local newFile = newproxy(true)
		local fileMeta = getmetatable(newFile)
		local fileData = {
			Id = HttpService:GenerateGUID(),
			Source = source,
			Name = file_name,
			Run = function(file, silent)
				return self:Load(file.Name, silent == nil and true)
			end
		}
		local locked = {
			"Id",
			"Run"
		}
		local expected = {
			Source = "string",
			Name = "string"
		}
		fileMeta.__metatable = "This metatable is locked."
		fileMeta.__tostring = function(self)
			return "file: "..fileData.Name
		end
		fileMeta.__len = function(self)
			return #fileData.Source
		end
		fileMeta.__index = function(self, index)
			return fileData[index]
		end
		fileMeta.__newindex = function(self, index, value)
			assert(not table.find(locked, index), index.." is a read-only value")
			local valueType = typeof(value)
			assert(typeof(fileData[index]) == expected[index], "type '"..expected[index].."' expected for "..index..", got '"..valueType.."'")
			if index == "Name" then
				files[fileData.Name] = nil
				files[value] = newFile
			end
			fileData[index] = value
		end
		fileMeta.__call = function(self, silent)
			return fileData.Run(newFile, silent)
		end
		local oldFile = files[file_name]
		if oldFile then
			local split = string.split(file_name, ".")
			if #split > 1 then
				extension = split[#split]
				table.remove(split, #split)
			end
			local name = table.concat(split, ".")
			local match = string.match(name, "%(%d+%)$")
			if match then
				local string_num = string.sub(match, 2, #match - 1)
				local num = tonumber(string_num)
				assert(num, "Invalid number for file counting: "..string_num)
				name = string.gsub(name, match, num + 1)
			else
				name = name.." (1)"
			end
			name = name..(extension and "."..extension or "")
			return self:Create(name, source)
		end
		files[file_name] = newFile
		return newFile
	end,
	GetAll = function(self)
		return files
	end,
	Get = function(self, file_name)
		return files[file_name]
	end,
	Load = function(self, file_name, silent)
		local file = self:Get(file_name)
		if file then
			if not silent then
				terminal.newlog("<font color = \"rgb(0, 255, 255)\">File/&gt; </font>executing file <font color=\"rgb(0, 255, 255)\">"..file.Name.."</font>.", Color3.new(1, 1, 1))
			end
			local split = string.split(file.Name, ".")
			table.remove(split, 1)
			local fileExtention = split[#split]
			if not fileExtention then
				terminal.newlog("No file extension found, please input one.")
				fileExtention = io.read()
			end
			local extension = extensions[fileExtention]
			assert(extension, "File extension '"..fileExtention.."' is not supported.")
			return extension(file)
		end
	end
}
env.file = file
local function exec(code, name)
	local new_thread = task.spawn(function()
		local success, fail = pcall(function()
			local func, fail = loadstring(code, name)
			assert(func, fail or "")
			args = lib.Utilities.Pack(setfenv(func, setmetatable(env, env.terminal.Internal.environmentMetatable))())
		end)
		if not success then
			env.terminal.error(fail)
		end
	end)
	table.insert(env.threadMng.Threads, new_thread)
	return table.unpack(args or table.create(0))
end
local function runcode(code)
	local split = string.split(code, ":")
	if inputHandler.expectingInput and string.lower(split[1]) ~= "%inp" then
		inputHandler.inputEvent:Fire(code)
		return
	end
	if #split > 1 and string.lower(split[1]) == "%inp" then
		table.remove(split, 1)
		code = table.concat(split, ":")
	end
	local richCode = code:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
	outputmsg("<font color = \"rgb(255, 255, 0)\">"..owner.Name.."/&gt; </font>"..richCode)
	return exec(code, "Terminal")
end
env.defaultRunCode = runcode
local slashes = {
    "|",
    "/",
    "-",
    "\\"
}
terminal = {
	createLoadingBar = function(legth)
		local data = {Progress = 0}
		local track = terminal.newlog()
		local texttrack = "["..string.rep("-", legth).."]"
		table.insert(env.threadMng.Threads, task.spawn(function()
			repeat
				local storage = {count = 0}
				local Progress = tonumber(data.Progress) or 0
				track.Text = "Progress: "..math.floor(Progress).."% "..slashes[math.floor((os.clock() * 10) % 3) + 1].."\n"..string.gsub(texttrack, ".", function(c)
					if c ~= "[" and c ~= "]" then
						storage.count = storage.count + 1
						if math.floor(data.Progress * length) > storage.count then
							return "="
						end
					end
				end)
				task.wait()
			until data.Progress >= 100
			local Progress = tonumber(data.Progress) or 0
			track.Text = "Progress: "..math.floor(Progress).."%\n["..string.rep("=", length).."]"
		end))
		return data
	end,
	exec = exec,
	extensions = extensions,
	Internal = {
		tostring = tostring,
		environmentMetatable = {
			__index = function(self, index)
				return rawget(self, index) or sandboxed_env[index]
			end,
			__newindex = function(self, index, value)
				rawset(self, index, value)
			end
		}
	}
}
env.terminal = terminal
function terminal.Internal:tabletostr(table_, name, main_table)
	local tostring = self.tostring
	if main_table then
		self.main_table = main_table
	else
		self.main_table = table_
	end
	local repeats = 0
	local result = ""
	local name = "["..tostring(name).."]"
	local result = name.." = {"
	lib.Loops.read(table_, function(i, v)
		local i = tonumber(i) and i or '"'..i..'"'
		if typeof(v) == "table" then
			if v == self.main_table then
				print(self.main_table)
				result = result.."\n  {CYCLIC},"
			else
				local new_str = self:tabletostr(v, i, self.main_table):gsub("\n", "\n  ")
				result = result.."\n  "..new_str..","
			end
		elseif typeof(v) == "Instance" then
			result = result.."\n  ["..i.."] = "..v:GetFullName()..","
		elseif typeof(v) == "string" then
			local back = string.find(v, "\n") and "[==[" or "'"
			local front = string.find(v, "\n") and "]==]" or "'"
			result = result.."\n  ["..i.."] = "..back..v..front..","
		else
			result = result.."\n  ["..i.."] = "..tostring(v)..","
		end
		repeats = repeats + 1
	end)
	if repeats < 1 then
		result = result.."!"
	end
	return string.sub(result, 1, #result - 1)..(repeats >= 1 and "\n}" or "}")
end
function terminal:read_table(table_)
	return self.Internal:tabletostr(table_, "\""..self.Internal.tostring(table_).."\"")
end
function tostring(arg)
	local arg = arg or ""
	if typeof(arg) == "table" then
		return terminal:read_table(arg)
	elseif typeof(arg) == "string" then
		return arg
	else
		return terminal.Internal.tostring(arg)
	end
end
local Services = {}
function Services:GetServices()
	local ServiceTable = {}
	lib.Loops.read(game:GetChildren(), function(i, v)
		xpcall(function()
			if Services[v.ClassName] then
				table.insert(ServiceTable,v)
			end
		end,
		function()
			table.insert(ServiceTable,false)
		end)
	end)
	return ServiceTable
end
env.Services = setmetatable(Services,{__index = function(self, index)
	local service = rawget(Services, index)
	if service then
		return service
	else
		local service = game:FindService(index)
		table.insert(Services, service)
		return service
	end
end})
return env