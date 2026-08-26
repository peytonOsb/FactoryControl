local validator = {}
validator.__index = validator

function validator.new(watchdog)
    local self = setmetatable({}, validator)
    self.message = watchdog:claimValidationJob()
    self.validator_id = math.random(100000000)

    self.watchdog = watchdog

    self.getContext = function()
        return watchdog:getContext() 
    end

    self.claimValidationJob = function()
        return watchdog:claimValidationJob() 
    end

    return self
end
 
function validator:build_baseCtx()
    local temp = self.getContext()

    local ctx = {
        session_id = temp.session_id,
        handshake_id = temp.handshake_id,
        protocol = self.message.envelope.protocol,
        protocol_version = self.message.envelope.protocol_version
    }

    return ctx
end

function validator.validate(msg, base_ctx, sender)
    local success, validator_or_err = pcall(require, "Modules.Watchdog.validator")
    
    if not success then 
        print("could not load validator")
        return false, {reason = "LoadError", expected = "table", got = validator_or_err}
    end

    local success, registry_or_err = pcall(require, "Modules.Watchdog.Registries.protocol_registry")

    print("registry_type:" .. type(registry_or_err))

    if not success or type(registry_or_err) ~= "table" then 
        print("could not load protocol registry")
        return false, {reason = "LoadError", expected = "table", got = registry_or_err}
    end

    local entry = registry_or_err[msg.type]
    
    print("r-entry type: " .. type(entry))

    if type(entry) ~= "table" then
        print("could not load protocol registry")
        return false, {reason = "RegistryLoadError", expected = "table", got = type(registry_or_err)}
    end

    local ctx = entry.context(base_ctx, sender)

    if type(ctx) ~= "table" then
        return false, {reason = "CtxTypeError", expected = "table", got = type(ctx)}
    end

    local success, schema_or_err = entry.schema(ctx)
    
    if not success then
        return false, {reason = "SchemaTypeError", expected = "table", got = type(schema_or_err)}
    end

    for key, value in pairs(ctx) do
        schema_or_err[key].value = value 
    end

    local success, err_or_nil = validator_or_err(schema_or_err, msg)

    if not success then 
        return false, err_or_nil
    end

    return true, {}
end

function validator.main(self, valid, invalid)    
    while true do
        if self.message == nil then
            table.remove(self.watchdog.workers.validators, 1)
            return true 
        end
        
        local sender, envelope = self.message.sender, self.message.envelope

        if type(envelope) ~= "table" then 
            return false, {reason="TypeError", expected = "table", got = type(envelope)} 
        end

        local base_ctx = self:build_baseCtx()
        local success, err = self.validate(envelope, base_ctx, sender)

        local t = {msg = envelope, sender = sender, valid = success, err = err, validator_id = self.validator_id}

        if success then 
            self.message = self:claimValidationJob()   
            table.insert(valid, t)
        else
            self.message = self:claimValidationJob()
            table.insert(invalid, t)
        end

        os.sleep(0.1)
    end
end

return validator