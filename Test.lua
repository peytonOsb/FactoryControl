--[[local m = require("Modules.ProductionModule")
local M = require("Modules.Manager")

Mod1 = {{"11", "12", "13"},{"12", "13"}}
Mod2 = {{"14", "15", "23"},{"10", "11"}}
Mod3 = {{"17", "18", "19"},{"8", "9"}}
Mod4 = {{"20", "21", "22"},{"6", "7"}}

US = 6

Mods = {m:ProductionModule(US, Mod1[1], Mod1[2]), 
        m:ProductionModule(US, Mod2[1], Mod2[2]),
        m:ProductionModule(US, Mod3[1], Mod3[2]),
        m:ProductionModule(US, Mod4[1], Mod4[2])}


local manager = M:CreateManager(Mods, {"40"})

manager:distribute(5, "cobblestone", 0.1)
]]--

local function send(id)
        local message  = textutils.serialize({["sender"] = "s", ["message"] = "Hello world"})
        print(type(message))
        rednet.send(id, message)
end

local function Listen()
        local _, message = rednet.recieve(nil, 1)
        local message = textutils.unserialiseJSON(message)
        print(message["message"])
end

send(4)