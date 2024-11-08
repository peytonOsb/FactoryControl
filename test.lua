local mc = require("lib/motorCont")

--motor initialization
local master = mc:new("7",-100,100)
local slave = mc:new("8",-100,100)
local slave2 = mc:new("9",-100,100)

master:setSlave(slave,true)
master:setSlave(slave,false)

master:run(20)
master:run(70,true)
