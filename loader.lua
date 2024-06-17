local gameId = game.PlaceId
local scripts = {
    [286090429] = {url = "https://api.luarmor.net/files/v3/verified/dca3e69649ed196af0ac6577f743a0ae.lua", thunder = true}, -- Arsenal
    [6872265039] = {url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/loadstring"}, -- BedWars
    [142823291] = {url = "https://pastebin.com/raw/zFnGiU7a"}, -- MM2
}

local scriptConfig = scripts[gameId]
if scriptConfig then
    if scriptConfig.thunder and getgenv().thunderclient then
        return
    elseif scriptConfig.thunder then
        getgenv().thunderclient = true
    end

    if scriptConfig.script_key then
        getgenv().script_key = scriptConfig.script_key
        getgenv().streamable = scriptConfig.streamable
        getgenv().autoload = scriptConfig.autoload
    end

    loadstring(game:HttpGet(scriptConfig.url))()
end
