local supervisor = {}
supervisor.__index = supervisor

function supervisor.new(watchdog)
    local self = setmetatable({}, supervisor)

    self.validator_limit = watchdog.validator_limit or 4
    self.router_limit = watchdog.router_limit or 4

    self.watchdog = watchdog

    self.validators = watchdog.workers.validators
    self.routers = watchdog.workers.routers

    self.msgQueue = watchdog.msgQueue
    self.routingQueue = watchdog.routingQueue

    return self
end

function supervisor:buildWorkers()
    print("current number of validators: ", #self.validators, "\nvalidators until limit: ", self.validator_limit - #self.validators)
    local success, validator_or_err = pcall(require, "Modules.Watchdog.Workers.Validator")

    if success then 
        print("validator worker found")
    else 
        print("validator module not found") 
        return {err = "NoFile",
                where = "ValidatorRetrieval",
                expected = "table",
                got = type(validator_or_err)
            }
    end

    local success, validator_or_err = pcall(require, "Modules.Watchdog.Workers.Validator")

    if not success then
        return false, {reason = "retrievalError", expected = "Modules.Watchdog.Workers.Validator", got = validator_or_err}
    else
        print("found validator worker")
    end

    print(#self.watchdog.msgQueue or 0)

    while #self.msgQueue > #self.validators and #self.validators < self.validator_limit do
        self.validators[#self.validators + 1] = validator_or_err.new(self.watchdog)
        print("validator built")
    end

    -- TODO: insert security layer generator

    -- TODO: insert router generator

    return true
end

function supervisor:compileProcesses()
    local workerProcesses = {}

    for _, worker in ipairs(self.validators) do
        table.insert(workerProcesses, 
            function() worker:main(self.watchdog.routingQueue, self.watchdog.invalidMsgs)
        end)
    end

    print("worker processes compiled")
    return workerProcesses
end

function supervisor:main()
    while true do
        if #self.msgQueue ~= 0 then
            self:buildWorkers()
            local processes = self:compileProcesses()

            print("validating Queue")
            parallel.waitForAll(table.unpack(processes))
            print("queue Validated")
        end

        os.sleep(0)
    end
end

return supervisor