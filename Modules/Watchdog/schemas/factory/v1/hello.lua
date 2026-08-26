local hello_SCHEMA = {
    type         = {required = true, type = "string", value = "hello"},      -- for multiple types use the keyword one_of_types
    protocol     = {required = true, type = "string", value = "factory_v1"}, -- for multiple values use the keyword one_of_values
    session_id   = {required = true, type = "string"},
    handshake_id = {required = true, type = "string"},
    receiver     = {required = true, type = "string"},
    protocol_version = {required = true, type = "string"},
    sender       = {required = true, type = "string"}
}

return hello_SCHEMA