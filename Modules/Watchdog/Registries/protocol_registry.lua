--file containing protocol handshake handlers and context builders
local handlers = require("Modules.Watchdog.handlers.handshake") 

-- dynamically load protocol schemas for the registry to distribute
local function build_schema(protocol, version, msg_type)
    local path = ("Modules.Watchdog.schemas.%s.%s.%s"):format(protocol, version, msg_type)
    print("protocol: ".. tostring(protocol) .. "\nversion: " .. tostring(version) .. "\ntype: " .. tostring(msg_type))
    local success, schema_or_err = pcall(require, path)
    
    if not success then 
        return false, {
            reason = "schema_load_failed", 
            expected = path, 
            got = schema_or_err,
            severity = "reset"
        } 
    end

    schema_or_err.protocol.value = protocol
    schema_or_err.protocol_version.value = version
    schema_or_err.type.value = msg_type
    
    return true, schema_or_err
end

--dynamically load message constructors for the registry to distribute
local function get_constructor(protocol, version, msg_type)
    local path = ("Modules.Watchdog.constructors.%s.%s.%s"):format(protocol, version, msg_type)

    local success, builder_or_err = pcall(require, path)
    
    if not success then 
        return false, {reason = "constructor_load_fail", expected = path, got = builder_or_err} 
    end

    return true, builder_or_err
end

local protocol_registry = {
    hello = {
        context = function(base_ctx, sender) 
            return handlers.build_envelope_ctx(base_ctx, sender) 
        end,

        schema = function(ctx)
            return build_schema(ctx.protocol, ctx.protocol_version, "hello") 
        end,

        handler = handlers.on_hello,

        constructor = function(ctx) 
            return get_constructor(ctx.protocol, ctx.version, "hello")
        end
    }
}

return protocol_registry