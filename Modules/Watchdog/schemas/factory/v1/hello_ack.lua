local hello_ack_SCHEMA = {
    type         = {required = true, type = "string", value = "hello_ack"},      -- for multiple types use the keyword one_of_types
    protocol     = {required = true, type = "string", value = "v1"}, -- for multiple values use the keyword one_of_values
    session_id   = {required = true, type = "string"},
    handshake_id = {required = true, type = "string"},
    receiver     = {required = true, type = "string"},

    identity = {
        required = true, 
        type = "table", 
        schema = require("Modules.Watchdog.schemas.v1.identity")
    },

    workload = {
        required = true, 
        type = "table", 
        schema = require("Modules.Watchdog.schemas.v1.workload")
    },

    health = {
        required = true, 
        type = "table", 
        schema = require("Modules.Watchdog.schemas.v1.health")
    }
}

return hello_ack_SCHEMA