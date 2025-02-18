Units = {}
Units.__index = Units

local DURATIONS = {{"gravel","crushing",250}}

function Units:generalized_units(...)
    local args = {...}

    -- args = [product, production method, belt_motor, ]
    --input validation
    assert(type(args[1]) == "string", "product must be a string")
    assert(type(args[2]) == "string", "production method must be a string")
    assert(type(args[3]) == "table","motor must be a motor object/table")

    --motor verification
    for index, arg in ipairs(args) do
        if index > 2 then
            if type(arg) ~= "table" then
                error("the object passed was not a motor: "..arg)
            end
        end
    end

    local module_duration

    --duration retrieval
    for index, data in ipairs(DURATIONS) do 
        if data[1] == args[1] and data[2] == args[2] then
            module_duration = data[3]
        end
    end

    --create the metatable for the modules properties
    local self_obj = setmetatable({}, Units)
    self_obj.product = args[1]
    self_obj.production_duration = module_duration
    self_obj.belt_motor = args[3]
    self_obj.output = 50

    --return the modules instance
    return self_obj
end

function Units:runAtRate()
local Production_duration = (self.production_duration - 20) / (math.max(0.25, math.min((4 * (self.belt_motor:getSpeed() / 50)) / math.log(self:getOutput(), 2), 20)))
end

function Units:getOutput()
    return self.output
end

function Units:setOutput(number)
    self.output(number)
end

return Units