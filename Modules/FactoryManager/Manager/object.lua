Manager = {}
Manager.__index = Manager

function Manager.new(Storage, Id)
    --variable assertions
    assert(type(Storage) == "table", "Storage should be a table of connected major vaults")
    assert(type(Id) == "number", "This feild should hold the factory's Id")

    --validate global item vaults or manager's use
    local store = {}
    for i = 1, #Storage do 
        assert(type(Storage[i]) == "number", string.format("%s was not a string", i))
        local name = string.format("create:item_vault_%d", tonumber(Storage[i]))
        local periph = peripheral.wrap(name)

        table.insert(store, {
            name = name,
            object = periph
        })
    end

    local self_obj = setmetatable({}, Manager)
    self_obj.storage = store
    self_obj.id = Id or nil
    return self_obj
end

--command to transfer file from manager to another computer
function Manager:TransferCommand(Receiver, Payload, sessionID, Pathway)
    local dispatcher = require("Manager.dispatcher")

    local Message = dispatcher:BuildRequest("transfer", Receiver, sessionID, Pathway, Payload) 

    dispatcher:SendMessage(self, Message, Receiver)
end

--TODO: implement sessionID tracking with logger
--get session ID for communications
function Manager:getSessionID()
    return nil
end

--build managed controller list and module characteristics
function Manager:BuildConfigCommand()
    local config = require("Manager.config")

    local Controllers = config.newProduction()

    return Controllers
end

--push config to slave production modules
function Manager:PushConfigCommand()
    local Config = Manager:BuildConfigCommand()

    for _, data in ipairs(Config)  do
        Manager:TransferCommand(data.computer, data, Manager:getSessionID(), "Configfile.lua")
        print("sending ", data.computer)
    end
end

function Manager:ListenCommand()
    local sender, payload, protocol = rednet.receive(nil, 0.1)

    if protocol == "response" then
        print("found")
    end
end

function Manager:initializeQueue()
    local queue = require(Manager.priorityQueue) 

    if not type(queue) == "table" then
        error("could not find priority queue constructor")
    end

    self.queue = queue.new()
end

function Manager:buildNetwork()
    local w = require(Manager.watchdog)

    if not type(watchdog) == "table" then 
        error("could not run watchdog at this time")
    end

    local watchdog = w.new()
    local computers = watchdog.validatedControllers(watchdog.scan())

    self.computers = computers
end

return Manager