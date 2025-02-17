Module = {}
Module.__index = Module

function Module:Module(size, Input)
    --Parameter assertion
    assert(type(size) == "number","size must be of type number")
    assert(type(Input) == "string","Product must be of type string")
    
    --object data setting
    local self_obj = setmetatable({}, Module)
    self_obj.size = size
    self_obj.input = Input
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
    local Quantity, RPM = Val[1], Val[2]
end

return Module