Module = {}
Module.__index = Module

-- args[1] == size, args[2] == Input type, args[3] == motors, args[4] == vaults
function Module:ProductionModule(...)
    -- motors = {belt, crush, slave}
    local args = {...}
    local vaults = {} 

    --Parameter assertion
    assert(type(args[1]) == "number","size must be of type number")
    assert(type(args[2]) == "string","input must be of type string")
    assert(type(args[3]) == "table","motor must be in a table as defined")
    
    
    -- Ensure exactly three motors are provided
    assert(#args[3] == 3, "Expected 3 motors in the table")

    -- Motor verification
    for i, motor in ipairs(args[3]) do
        assert(type(motor) == "string", "Motor at index " .. i .. " is not a valid table: " .. tostring(motor))
    end

    --Storage Verification
    if args[4] ~= nil then
        for i = 1, #args[4] do 
            local vaultString = string.format("create:item_vault_%d", tonumber(args[4][i]))
            local peripheral = peripheral.wrap(vaultString)
            table.insert(vaults, peripheral)
        end
    end

    -- Library Verification
    local success, motor_controller = pcall(require, "LIB/motor_controller")
    if not success then error("Could not find motor_controller library") end

    local success, BST = pcall(require, "LIB/BST")
    if not success then error("Could not find Binary Search Tree library") end

    local success, PIDController = pcall(require, "LIB/PIDController")
    if not success then error("Could not find PIDController library") end


    --object data setting
    local self_obj = setmetatable({}, Module)
    self_obj.size = args[1]
    self_obj.input = args[2]
    self_obj.belt = motor_controller:new(args[3][1], 256, 0, 0.1, 0.1, 0.1)
    self_obj.crush = motor_controller:new(args[3][2], 256, 0, 0.1, 0.1, 0.1)
    self_obj.slave = motor_controller:new(args[3][3], 256, 0, 0.1, 0.1, 0.1)
    self_obj.vaults = vaults

    self_obj.crush:setSlave(self_obj.slave, true)
    return self_obj
end

function Module:setCrushRate(number, TOL)
    --parameter assertion
    assert(type(number) == "number", "output rate must be a number")

    --external file validation
    local BST = require("LIB/BST")
    local lookup = require(string.format("Modules/LookupTables.%s",self.input))

    local index = math.floor(number)
    local table = lookup[index]

    table = BST:lookupTableToBST(table)

    local Val = table:search(number,TOL).value
    local Quantity, RPM = Val[2], Val[3]

    self.belt:run(RPM, true, 0)
    self.crush:run(RPM, true, 0)
end

function Module:getOutput(quantity, rpm)
    local denominator = math.max(0.25, math.min((25 * math.log(quantity, 2)) / (2 * rpm), 20))
    return ((quantity / (230 / denominator)) + 1) * 20
end

function Module:getMaxOutput()
    return self:getOutput(64, 256) * self.size
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

function Module:getSize()
    return self.size
end


function Module:setInputSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0, "Belt speed must be a non-negative number")
    self.belt:run(Speed)
end

function Module:getStorage()
    return self.vaults
end

return Module