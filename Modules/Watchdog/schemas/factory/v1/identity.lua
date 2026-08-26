local identity_SCHEMA = {
            boot_id = {required = true, type = "string"},
            roles = {required = true, type = "table"},
            software_version = {required = true, type = "string"},
            protocol_version = {required = true, type = "string"},
            features = {required = true, type = "table"}
        }

return identity_SCHEMA