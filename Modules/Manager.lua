Manager = {}
Manager.__index = Manager

function Manager:CreateManager(Production, Storage)
    --variable assertions
    assert(type(Production) == "table", "Production should be a table of connected production modules")
    assert(type(Storage) == "table", "Storage should be a table of connected major vaults")

end