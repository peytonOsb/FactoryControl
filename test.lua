local mc = require("lib/motorCont")

--motor initialization
local master = mc:new("7",100,100)
local slave = mc:new("8",100,100)
local slave2 = mc:new("9",100,100)

master:setSlave(slave,false)
master:setSlave(slave2,false)

local slaves = master:getSlaves()

for i = 1, #slaves do
    print(master.slaves[i]:getId())
end