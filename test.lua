local mc = require("lib/motorCont")

--parameter declaration
local max = 200
local min = 100

--motor initialization
local master = mc:new("7",-100,100)
local slave = mc:new("8",-100,100)
local slave2 = mc:new("9",-100,100)

--follower initialization
master:setSlave(slave,true)
master:setSlave(slave2,false)


