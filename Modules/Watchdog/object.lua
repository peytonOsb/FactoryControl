--[[
The watchdog is a gateway with full control over determining whether or not a node may speak to the remainder of the system
All system IO must pass through the watchdog at any given point in time.
This system must be capable of 
]]

local watchdog = {}
watchdog.__index = watchdog

watchdog.STATE_RECOVERING = "recovering"
watchdog.STATE_ALIVE = "alive"
watchdog.STATE_ISOLATED = "isolated"
watchdog.STATE_STALE = "stale"
watchdog.STATE_DEAD = "dead"


-- watchdog node constructor
function watchdog.new(opts)
    local self = setmetatable({}, watchdog)

    opts = opts or {}

    --missed message thresholds for state change
    opts.heartbeat_interval = opts.heartbeat_interval or 1
    opts.stale_after = opts.stale_after or 3    
    opts.dead_after = opts.dead_after or 6
    opts.kill_after = opts.kill_after or 9

    --identitifying characteristics
    opts.manager_id = opts.manager_id or 0
    opts.session_id = opts.session_id or math.random(1,1e10)
    opts.computer_id= opts.computer_id or os.getComputerID()

    self.session_id = opts.session_id
    self.manager_id = opts.manager_id
    self.computer_id = self.computer_id

    --thread limits
    self.validator_limit = opts.worker_limit or 4
    self.router_limit = opts.router_limit or 2

    --watchdog validation queue
    self.msgQueue = {}
    self.validationQueue = {}
    self.validating = {}
    self.routingQueue = {}
    self.routing = {}
    self.waitingACK = {}

    self.invalidMsgs = {}

    --time function injection
    self.now = opts.now or function() return os.clock() end

    --node registry for keeping track of active controllers
    --valid:         nodes[node_id] = {boot_id, state, last_seen, roles, version, features, missed} or
    --startup stale: nodes[node_id] = {state, last_seen, missed, error}
    self.nodes = {}
    self.allowed_nodes = {}

    --worker thread registry
    self.workers = {}
    self.workers.validators = {}
    self.workers.routers = {}

    
    self.config = opts

    return self
end

--set the watchdogs allowed node list (messages triggering this command should be validated first)
function watchdog:set_allowed_nodes(node_list)
    print(type(node_list))
    if type(node_list) ~= "table" then
        return false, {reason = "TypeError", expected = "table", got = type(node_list)}
    end

    self.allowed_nodes = node_list
end

--push a new node id to the allowed node list
function watchdog:push_allowed_node(node_id)
    assert(type(node_id) == "number", "node_id must be a number")

    local present = false
    for _, id in ipairs(self.allowed_nodes) do
        if id == node_id then
            present = true
            break 
        end
    end

    if not present then 
        table.insert(self.allowed_nodes, node_id) 
    else
        error("node is already present")
    end
end

--remove a node id from the allowed node list
function watchdog:pop_allowed_node(node_id)
    assert(type(node_id) == "number", "node_id must be a number")

    local present = false
    for _, id in ipairs(self.allowed_nodes) do
        if id == node_id then
            present = true
            break 
        end
    end

    if present then 
        table.remove(self.allowed_nodes, node_id) 
    else
        error("node not present in node list")
    end
end

-- increase the number of heartbeats a node has missed  
function watchdog:strike(node_id)
    local node = self.nodes[node_id]
    node.missed_heartbeats = node.missed_heartbeats + 1
end

-- reset missed heartbeat strikes on a node 
function watchdog:strike_reset(node_id)
    local node = self.nodes[node_id]
    node.missed_heartbeats = 0
end

--enter message into queue for threaded validation
function watchdog:enqueue(msg, sender)
    local Queue = self.msgQueue or {}

    if Queue then
        Queue[#Queue + 1] = {sender = sender, envelope = msg}
        self.msgQueue = Queue
    else
        return false, {reason = "TableNotFound", expected = "table", got = type(Queue)}
    end
end

-- remove message from validation queue
function watchdog:dequeue(pos)
    if type(pos) ~= "number" then
        return false, {reason = "TypeError", expected = "string", got = type(pos)}
    end 

    table.remove(self.msgQueue, pos)

    return true
end

-- edit with actual handshake ID for messages
function watchdog:getContext()
    return {
        session_id = self.session_id,
        handshake_id = "nil"
    }
end

function watchdog:claimValidationJob()
    local success, message = pcall(table.remove, self.msgQueue, 1)

    if success then
        return message
    end
end

function watchdog:claimRoutingJob()
    local success, message = pcall(table.remove, self.routingQueue, 1)

    if success then
        return message
    end
end

return watchdog