local test_messages = {

    -- ===================== VALID =====================

    {
        type = "hello",
        protocol = "factory",
        session_id = "nil",
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
    },

    -- ===================== INVALID: missing fields =====================
    {
        type = "hello",
        protocol = "factory",
        session_id = "nil",
        handshake_id = "nil",
        receiver = "controller",
        protocol_version = "v1",
        sender = "12"
    },

    {
        type = "hello",
        protocol = "factory",
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
        -- missing session_id
    },

    {
        type = "hello",
        protocol = "factory",
        session_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
        -- missing handshake_id
    },

    -- ===================== INVALID: wrong types =====================

    {
        type = "hello",
        protocol = "factory",
        session_id = nil, -- actual Lua nil (missing value)
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
    },
    
    {
        type = "hello",
        protocol = "factory",
        session_id = "nil",
        handshake_id = 12345, -- wrong type
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
    },

    -- ===================== INVALID: wrong values =====================

    {
        type = "HELLO", -- wrong case
        protocol = "factory",
        session_id = "nil",
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
    },

    {
        type = "hello",
        protocol = "wrong_protocol",
        session_id = "nil",
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
    },

    -- ===================== INVALID: malformed =====================

    "not a table",

    42,

    -- ===================== EDGE CASES =====================

    {
        type = "hello",
        protocol = "factory",
        session_id = "", -- empty string (should pass type, fail semantic if enforced)
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9"
    },

    {
        type = "hello",
        protocol = "factory",
        session_id = "nil",
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = 9 -- wrong type
    },

    {
        type = "hello",
        protocol = "factory",
        session_id = "nil",
        handshake_id = "nil",
        receiver = "manager",
        protocol_version = "v1",
        sender = "9",
        extra_field = "ignored"
    }
}
return test_messages