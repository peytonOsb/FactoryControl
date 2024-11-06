local mc = require("lib/motorCont")

--parameter declaration
local max = 200
local min = 100

--motor initialization
local master = mc:new("7",max,min)
local slave = mc:new("8",max,min)
local slave2 = mc:new("9",max,min)

--follower initialization
master:setSlave(slave,true)
master:setSlave(slave2,false)

--run testing
master:run(50)
print(master:getSpeed())

