--[[
The watchdog is a gateway with full control over determining whether or not a node may speak to the remainder of the system
All system IO must pass through the watchdog at any given point in time.
This system must be capable of 
]]

local watchdog = {}
watchdog.__index = watchdog

watchdog.STATE_ALIVE = "alive"
watchdog.STATE_STALE = "stale"
watchdog.STATE_DEAD = "dead"
watchdog.STATE_RECOVERING = "recovering"
watchdog.STATE_ISOLATED = "isolated"

-- watchdog node constructor
function watchdog.new(opts)
    local self = setmetatable({}, watchdog)

    opts = opts or {}

    --missed message thresholds for state change
    opts.heartbeat_interval = opts.heartbeat_interval or 1.0
    opts.stale_after = opts.stale_after or 3    
    opts.dead_after = opts.dead_after or 6
    opts.kill_after = opts.kill_after or 10

    --identitifying characteristics
    opts.manager_id = opts.manager_id or 0
    opts.session_id = opts.session_id or math.random(1,1e10)

    --time function injection
    self.now = opts.now or function() return os.clock() end

    --node registry for keeping track of active controllers
    --valid:         nodes[node_id] = {boot_id, state, last_seen, roles, version, features, missed} or
    --startup stale: nodes[node_id] = {state, last_seen, missed, error}
    self.allowed_nodes = {}
    self.active_nodes = {}
    self.inactive_nodes = {}
    self.unknown_nodes = {}

    --manager/session identity
    self.session = opts.session or tostring(math.random(1, 1e9))
    self.config = opts

    return self
end

--set the watchdogs allowed node list (messages triggering this command should be validated first)
function watchdog:set_allowed_nodes(node_list)
    assert(type(node_list) == "table", "allowed node_list must be a table")

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


function watchdog:on_unknown_acknowledgement()
end

--validate task assignment messages
function watchdog:on_task_assignment(msg, protocol)
end

function watchdog:on_task_ack(msg, protocol)
end

function watchdog:heartbeat(opts)
end

--ping all connected computers and track identities
function watchdog:onHelloACK(controller_id, expected_hello, response, missed_count)
    local ok = false
    local states = {}

    if type(response) == "table"
        and response.Type == "hello_ack" 
        and response.session == expected_hello.session 
        and response.handshake_id == expected_hello.handshake_id 
        and type(response.identity) == "table"
    then

        self.nodes[controller_id] = {
            boot_id   = response.identity.boot_id, --TODO: check boot_id
            state     = watchdog.STATE_RECOVERING, 
            last_seen = self.now(),
            roles     = response.identity.roles,    --TODO: build role compatibility checker
            version   = response.identity.version,  --TODO: build version compatibility checker
            features  = response.identity.features, --TODO: build feature compatibility checker
            missed    = missed_count
        }
        
        ok = true
    end

    --if response was either not good or took too long then we need to check state transition
    if not ok then
        self.nodes[controller_id] = {
            state     = watchdog.STATE_STALE,
            last_seen = self.nodes[controller_id] or nil,
            missed    = missed_count,
        }
    end

    return {status = ok, node = self.nodes[controller_id]}
end


--isolate nodes unable to response within 3 heartbeats
function watchdog:isolate(node_id, reason)
end

--kill nodes which after being isolated are incapable of responding after 10 heartbeats and update 
function watchdog:kill(node_id, reason)
end

--update scheduler with findings 
function watchdog:update(scheduler)

end

function watchdog:scan()
    local attachments = peripheral.getNames()
    local computers = {}

    --find all computers attached to manager's network
    for _, obj in ipairs(attachments) do
        if peripheral.getType(obj) == "computer" then
            table.insert(computers, obj)
        end
    end

    return computers
end


return watchdog