M = {}
M.__index = M

--manager operation modes describe the type fo node the manager manages 
M.MODE_STORE = "storage" 
M.MODE_FACT = "factory"
M.MODE_LOG = "logistical"
M.MODE_POW = "power"

--Manager contructor
function M.new(opts)
    local self_obj = setmetatable(M, {}) 
    local id = (opts and opts.id) or 0 
    local mode = (opts and opts.mode) or M.MODE_FACT
    return self_obj
end

function M:initializeQueue()
    local queue = require(Manager.priorityQueue) 

    if not type(queue) == "table" then
        error("could not find priority queue constructor")
    end

    self.queue = queue.new()
end

function M:initializeWatchdog()
    local watchdog = require(Manager.watchdog)

    if not type(watchdog) == "table" then
        error("could not find watchdog module")
    end

    self.watchdog = watchdog.new()
end


function M:validateStorages()
    
end