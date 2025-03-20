Manager = {}
Manager.__index = Manager

function Manager:CreateManager(Modules, Storage)
    --variable assertions
    assert(type(Modules) == "table", "Production should be a table of connected production modules")
    assert(type(Storage) == "table", "Storage should be a table of connected major vaults")

    for i = 1, #Modules do
        local success, Modules = pcall(assert, type(Modules[i].setCrushRate) == "function")
        if not success then error(string.format("one or more of the given modules was not fo type module")) else print("Modules processed successfully") end
    end

    local store = {}
    for i = 1, #Storage do 
        assert(type(Storage[i]) == "string", string.format("%s was not a string", i))
        table.insert(store, peripheral.wrap(string.format("create:item_vault_%d", tonumber(Storage[i]))))
        print("processed storages successfully")
    end

    local mod = {}
    for index, value in ipairs(Modules) do
        mod[string.format("m%d", index)] = value
    end

    local self_obj = setmetatable({}, Manager)
    self_obj.modules = Modules
    self_obj.storage = store
    return self_obj
end

function Manager:distribute(input, inputType, TOL)
    print(input, inputType, TOL)

    local size = 0
    for _, module in ipairs(self.modules) do
        size = size + module:getSize()        
    end

    print("determined factory size to be: ", size)
    print("desired output: ",input)

    for _, module in ipairs(self.modules) do
        local output = input / size * module:getSize()
        print(output)
        module:setCrushRate(output, inputType, TOL)
    end
end

return Manager