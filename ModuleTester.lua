local MC = require("motor_controller")
local file = io.open("moduleData", "a")

local function all_trim(s)
    return s:match( "^%s*(.-)%s*$" )
end

-- Initialization of testing variables
local speed = 1
local iterator = 1
local timer = os.startTimer(3)

-- Initialization of testing module objects
local belt = MC:new("6", 256, 0)
local M_Crusher = MC:new("4", 256, 0)
local S_Crusher = MC:new("5", 256, 0)
local collector = peripheral.wrap("right")

-- Main loop for data collection
while speed < 256 do

end

-- Close the file
io.close(file)
