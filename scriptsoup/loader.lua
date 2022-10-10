local function gassert(t)
  for i,v in pairs(t) do
    assert(unpack(v))
  end
end
local function importfstr(n : "Username",r : "Repository", b : "Branch",el : "Location",fn : "File",fe : "Extension", raw : "Raw")
  gassert({
    {r,"Missing repository"},
    {fe,"Missing file extension"},
    {fn,"Missing file name"},
  })
  local n = n or sets.User
  local b = b or "main"
  local el = el or ""
  if raw then
    t = "https://raw.githubusercontent.com/"
    t2 = ""
  else
    t = "https://github.com/"
    t2 = "blob/"
  end
  local fstr = string.format("%s%s/%s/%s%s%s/%s.%s",t,n,r,t2,b,fn,fe)
  return fstr
end
local sets = {User = "BRY402"}
local function load(n)
	local fn,fe = unpack(string.split(n,"."))
	importfstr(sets.User,"random-scripts","main","scriptsoup",fn,fe or "lua",true)
end
return load
