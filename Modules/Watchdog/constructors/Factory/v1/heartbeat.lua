local function heartbeat_constructor(receiver, session_id, handshake_id)
    local outbound_heartbeat = {
        type         = "heartbeat",
        protocol     = "factory",
        version      = "v1",
        receiver     = receiver,
        sender       = os.getComputerID(),
        session_id   = session_id,
        heartbeat_id = handshake_id, -- per-node or per-attempt
    }

    return outbound_heartbeat
end

return heartbeat_constructor