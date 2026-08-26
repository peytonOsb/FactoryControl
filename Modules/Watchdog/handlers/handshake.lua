local handlers = {}

function handlers.build_envelope_ctx(base_ctx, sender)
    return {
        session_id = base_ctx.session_id,
        handshake_id = base_ctx.handshake_id,
        sender = sender,
        protocol = base_ctx.protocol,
        protocol_version = base_ctx.protocol_version
    }
end

function handlers.on_hello(watchdog, sender, msg)    
    --else route the valid message to the desired recipient 
    if msg.receiver == watchdog.computer_id then
        if watchdog.nodes[sender] == nil then
            watchdog.nodes[sender] = {}
        end

        local node = watchdog.nodes[sender] 

        watchdog:strike_reset(sender)

        node.protocol = msg.protocol
        node.protocol_version = msg.protocol_version

        node.state = watchdog.STATE_RECOVERING
        node.last_seen = watchdog.now   
    else
        return true, msg --replace with routing logic
    end

    return true, nil
end



return handlers