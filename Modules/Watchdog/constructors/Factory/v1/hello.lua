local function hello_constructor(receiver, sender, session_id, handshake_id)
    local hello = {
        type             = "hello",
        protocol         = "factory",
        software_version = "v1",
        receiver         = receiver,
        sender           = sender,
        session_id       = session_id,
        handshake_id     = handshake_id, -- per-node or per-attempt nonce
    }

    return hello
end

return hello_constructor