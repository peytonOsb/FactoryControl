Module = {}
Module.__index = Module

-- args[1] == size, args[2] == motors, args[3] == vaults
function Module:ProductionModule(...)
    -- motors = {belt, crush, slave}
    local args = {...}
    local vaults = {} 

    --Parameter assertion
    assert(type(args[2]) == "table","motor must be in a table as defined")
    
    
    -- Ensure exactly three motors are provided
    assert(#args[2] == 3, "Expected 3 motors in the table")

    -- Motor verification
    for i, motor in ipairs(args[2]) do
        assert(type(motor) == "string", "Motor at index " .. i .. " is not a valid table: " .. tostring(motor))
    end

    --Storage Verification
    if args[3] ~= nil then
        for i = 1, #args[3] do 
            local vaultString = string.format("create:item_vault_%d", tonumber(args[3][i]))
            local peripheral = peripheral.wrap(vaultString)
            table.insert(vaults, peripheral)
        end
    end

    -- Library Verification
    local success, motor_controller = pcall(require, "LIB/motor_controller")
    if not success then error("Could not find motor_controller library") end

    local success, _ = pcall(require, "LIB/BST")
    if not success then error("Could not find Binary Search Tree library") end

    local success, _ = pcall(require, "LIB/PIDController")
    if not success then error("Could not find PIDController library") end

    local success, _ = pcall(require, "Modules.LookupTables.RateTable") 
    if not success then error("require rate table for crushers") end


    --object data setting
    local self_obj = setmetatable({}, Module)
    self_obj.size = args[1]
    self_obj.belt = motor_controller:new(args[2][1], 256, 0, 0.1, 0.1, 0.1)
    self_obj.crush = motor_controller:new(args[2][2], 256, 0, 0.1, 0.1, 0.1)
    self_obj.slave = motor_controller:new(args[2][3], 256, 0, 0.1, 0.1, 0.1)
    self_obj.vaults = vaults

    self_obj.crush:setSlave(self_obj.slave, true)
    return self_obj
end

function Module:setCrushRate(number, input, TOL)
    --parameter assertion
    assert(type(number) == "number", "output rate must be a number")
    assert(type(input) == "string", "input type must be a string") 

    

    --external file validation
    local success, BST = pcall(require, "LIB/BST") -- find binary search tree library
    if not success then error("could not find Binary tree library") else print("found binary lookup tree library") end

    local success, Rates = pcall(require, "Modules.LookupTables.RateTable") -- find rate lookup table 
    if not success then error("could not find lookup table for rates") else print("found Rate lookup table") end

    local Rate = string.format("Modules.LookupTables.%d", Rates[input][1]) --find the Recipe's processing rate in Rates Table

    local success, tab = pcall(require, Rate) -- find the specific lookup table
    if not success then error(string.format("could not find Rate table for this item: %s",input)) else print("found the necessary lookup table") end

    tab = BST:lookupTableToBST(tab[math.floor(number / self.size)])
    print("converted lookup table to binary search tree" )

    local RPM = tab:search(number/self.size, TOL).value[3]
    print("found necessary RPM: ", RPM )


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