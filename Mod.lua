Module = {}
Module.__index = Module

-- args[1] == size, args[2] == Input type, args[3] == motors
function Module:Module(...)
    -- args[1] == size, args[2] == Input type, args[3] == motors
    -- motors = {belt, crush, slave}
    local args = {...}

    --Parameter assertion
    assert(type(args[1]) == "number","size must be of type number")
    assert(type(args[2]) == "string","Product must be of type string")
    assert(type(args[3]) == "table","motor must be in a table as defined")
    
    -- Ensure exactly three motors are provided
    assert(#args[3] == 3, "Expected 3 motors in the table")

    -- Motor verification
    for i, motor in ipairs(args[3]) do
        assert(type(motor) == "string", "Motor at index " .. i .. " is not a valid table: " .. tostring(motor))
    end

    -- Library Verification
    local success, motor_controller = pcall(require, "motor_controller")
    if not success then error("Could not find motor_controller library") end

    local success, BST = pcall(require, "BST")
    if not success then error("Could not find Binary Search Tree library") end

    local success, PIDController = pcall(require, "PIDController")
    if not success then error("Could not find PIDController library") end


    --object data setting
    local self_obj = setmetatable({}, Module)
    self_obj.size = args[1]
    self_obj.input = args[2]
    self_obj.belt = motor_controller:new(args[3][1], 256, 0, 0.1, 0.1, 0.1)
    self_obj.crush = motor_controller:new(args[3][2], 256, 0, 0.1, 0.1, 0.1)
    self_obj.slave = motor_controller:new(args[3][3], 256, 0, 0.1, 0.1, 0.1)

    self_obj.crush:setSlave(self_obj.slave, true)
    return self_obj
end

function Module:setCrushRate(number, TOL)
    --parameter assertion
    assert(type(number) == "number", "output rate must be a number")

    --external file validation
    local BST = require("BST")
    local lookup = require(string.format("LookupTables.%s",self.input))

    local index = math.floor(number)
    local table = lookup[index]

    table = BST:lookupTableToBST(table)

    local Val = table:search(number,TOL).value
    local Quantity, RPM = Val[2], Val[3]

    self.belt:run(RPM)
    self.crush:run(RPM)
end

function Module:getElectricityUsage()
    local belt_speed = self.belt:getSpeed()
    local crusher_speed = self.crush:getSpeed()
    return (0.9 * belt_speed) + 2 * (0.9 * crusher_speed)
end

function Module:setCrushingSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0,"Crushers must run at a speed greater than zero")
    self.crush:run(Speed)
end

function Module:setInputSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0, "Belt speed must be a non-negative number")
    self.belt:run(Speed)
end

return Module