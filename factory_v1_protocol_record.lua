-- ============================================================
-- Watchdog internal node record (NOT a wire/message format)
-- ============================================================
watchdog_node_record = {
    -- identity/capabilities (learned from HELLO_ACK + kept as cached truth)
    boot_id           = nil,     -- string
    roles             = nil,     -- map/set: { production=true, logger=true, ... }
    software_version  = nil,     -- string, e.g. "1.3.0"
    protocol_version  = nil,     -- string, e.g. "v1"
    features          = nil,     -- map/set: { file_transfer=true, task_cancel=true, ... }
    protocol          = nil,     -- the protocol used to talk to the desired device

    -- watchdog-derived health state (computed, not reported)
    state             = nil,     -- "recovering" | "alive" | "stale" | "dead" | "isolated"
    last_seen         = nil,     -- number (monotonic time from watchdog.now())
    missed_heartbeats = nil,     -- number (consecutive misses)

    -- diagnostics (may be derived from node reports)
    last_err          = nil,     -- string code or short message
    error_count_win   = nil,     -- number (define window: "since last heartbeat" recommended)

    -- last known workload snapshot (reported, cached)
    mode              = nil,     -- "idle" | "busy" | "faulted" | "paused"
}

-- ===========================================================
-- Default message Envelope
-- ===========================================================
envelope = {
    type             = "hello",
    protocol         = "factory",
    protocol_version = "v1",
    reciever         = "string",
    sender           = "string",
    session_id       = "string",
    handshake_id     = "string", -- per-node or per-attempt nonce
}

-- ============================================================
-- Outbound HELLO (manager/watchdog -> controller)
-- ============================================================
outbound_hello = {
    type             = "hello",
    protocol         = "factory",
    software_version = "v1",
    reciever         = "string",
    sender           = "string",
    session_id       = "string",
    handshake_id     = "string", -- per-node or per-attempt nonce
}

-- ============================================================
-- Inbound HELLO_ACK (node -> manager/watchdog)
-- ============================================================
hello_ack_format = {
    type         = "hello_ack",
    protocol     = "factory_v1",
    reciever     = "string",
    sender       = "sender",
    session_id   = "string",
    handshake_id = "string",
    
    -- node identifying Information
    identity = {
        boot_id          = "string",
        roles            = {},       -- map/set: { production=true, logger=false, ... }
        software_version = "string",
        protocol_version = "string", -- can duplicate top-level protocol or be explicit
        features         = {},       -- map/set: { file_transfer=true, task_cancel=true, ... }
    },

    -- work state snapshot for managerial use
    workload = {
        mode                      = "string",     -- "idle"|"busy"|"faulted"|"paused"
        current_task_id           = "string|nil",
        task_phase                = "string|nil", -- controlled enum, not freeform
        queue_depth               = "string",
        estimated_completion_time = "number|nil",
        task_started_at           = "number|nil",
        last_progress_at          = "number|nil"
    },

    -- node health information
    health = {
        last_err        = "string",      -- short error code
        error_count_win = "number",      -- within the last 5 heartbeats
        faulted         = "boolean|nil", 
        fault_code      = "string|nil"
    }
}

-- ============================================================
-- Heartbeat (manager/watchdog -> controller)
-- ============================================================
outbound_heartbeat = {
    type         = "heartbeat",
    protocol     = "factory_v1",
    reciever     = "string",
    sender       = "string",
    session_id   = "string",
    heartbeat_id = "string", -- per-node or per-attempt
}

-- ============================================================
-- Heartbeat ACK (controller -> manager/watchdog)
-- ============================================================
heartbeat_ack_format = {
    type         = "hello_ack",
    protocol     = "factory_v1",
    reciever     = "string",
    sender       = "string",
    session_id   = "string",
    heartbeat_id = "string",
    
    -- node identifying Information which allows for restarts to be detected
    boot_id = "string",

    -- work state snapshot for managerial use
    workload = {
        mode                      = "string",     -- "idle"|"busy"|"faulted"|"paused"
        current_task_id           = "string|nil",
        task_phase                = "string|nil", -- controlled enum, not freeform
        queue_depth               = "number",
        estimated_completion_time = "number|nil",
        task_started_at           = "number|nil",
        last_progress_at          = "number|nil"
    },

    -- node health information
    health = {
        last_err        = "string",      -- short error code
        error_count_win = "number",      -- within the last 5 heartbeats
        faulted         = "boolean|nil", 
        fault_code      = "string|nil"
    }
}