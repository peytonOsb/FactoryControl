Module = {}
Module.__index = Module

-- table of motors {{belt, crusher,slave}, ...}, vaults {}, module size, module type
function Module:CreateProductionModule(...)
    local args = {...}

    -- motor table verification
    for index, value in ipairs(args[1]) do 
        -- assert the IDs supplied are numbers
        assert(type(args[1][index]) == "number", string.format("The ID found in index %d in motor table was not a number", index))

        --ensure the provided ID matches a physical motor
        local stem = string.format("electric_motor_%d", value)
        local status, _ = pcall(peripheral.wrap, stem)
        if status == "false" then error("Could not find motor peripheral" .. stem) end
    end

    local vaults = {}

    --Vault table verification 
    for index, value in ipairs(args[2]) do
        --assert IDs supplied are numbers
        assert(type(args[1][index]) == "number", string.format("The ID found in index %d in vault table was not a number", index))

        --ensure provided ID matches a physical vaukt
        local stem = string.format("create:item_vault_%d", value)
        local success, vault = pcall(peripheral.wrap, stem)
        if not success then 
            error("Could not find vault peripheral" .. stem) 
        else
            table.insert(vaults, {name = stem, object = vault} )
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

    --object value definition
    local self_obj = setmetatable({}, Module)
    self_obj.size = args[3]
    self_obj.belt = motor_controller:new(args[1][1], 256, 0, 0.1, 0.1, 0.1)
    self_obj.crush = motor_controller:new(args[1][2], 256, 0, 0.1, 0.1, 0.1)
    self_obj.slave = motor_controller:new(args[1][3], 256, 0, 0.1, 0.1, 0.1)
    self_obj.vaults = vaults
    self_obj.type = args[4]
    self_obj.task = nil

    self_obj.crush:setSlave(self_obj.slave, true)
    return self_obj
end

function Module:ListenCommand()
    local sender, payload, protocol = rednet.receive(nil, 0.1)

    if protocol == "transfer" then
        print("found")
    end
end

function Module:SendCommand()
    
end
return Module