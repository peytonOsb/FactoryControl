local config = {}
config.__index = config

function config.newManager()
    local self_obj = setmetatable({},config)

    --Manager Module Specifications
    self_obj.manager = {storages = {14}, id = 1}
    self_obj.id = 0
    return self_obj
end

function config.newProduction()
    local self_obj = setmetatable({},config)

    --Manager Module Specifications
    self_obj.production = {{motors = {"11", "12", "13"}, vaults = {"12", "13"}, size = 6, type = "crusher", computer = 23}, 
                           {motors = {"14", "15", "23"}, vaults = {"10", "11"}, size = 6, type = "crusher", computer = nil},
                           {motors = {"17", "18", "19"}, vaults = {"8", "9"}, size = 6, type = "crusher", computer = nil},
                           {motors = {"20", "21", "22"}, vaults = {"6", "7"}, size = 6, type = "crusher", computer = nil}}
    return self_obj
end

return config