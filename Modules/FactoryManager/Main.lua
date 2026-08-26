local MConfig = require("Manager.config")
local ManagerModule = require("Manager.object")

-- build the list of valid controller connectons
local Validcontrollers = require("Manager.startup")


-- build the manager object and launch
local config = MConfig:BuildManager()
local manager = ManagerModule:CreateManager(config.manager.storages, config.manager.id)

--Push internal config to respective controllers
if #Validcontrollers > 0 then
    manager:PushConfigCommand()

    while true do 
        manager:ListenCommand()
    end
end


--launch into manager main loop
 

