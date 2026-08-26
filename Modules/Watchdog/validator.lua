-- msg = {{required = bool, type = type, value = expected}
local function SCHEMAvalidator(schema, msg)
    -- throws false when the rule is invalid
    if type(msg) ~= "table" then
        return false, {expected = "table", got = type(msg)}
    end 

    local missing, type_err, value_err = {}, {}, {}

    for field, rule in pairs(schema) do
        if type(rule) ~= "table" then 
            value_err[field] = {reason = "invalid schema rule", expected = "table", got = type(rule)}
        end
        
        local v = msg[field]
        local required = rule.required == true

        if v == nil and required then 
            table.insert(missing, field)
        else
            -- type check
            if rule.type ~= nil then
                if type(v) ~= rule.type then     
                    type_err[field] = {expected = rule.type, got = type(v)}
                end
            elseif rule.one_of_types ~= nil then 
                if type(rule.one_of_types) ~= "table" then
                    value_err[field] = {reason = "schema_one_of_types_not_table", expected = "table", got = type(rule.one_of_types)}
                else
                    local ok = false

                    for i = 1, #rule.one_of_types do
                        if type(v) == rule.one_of_types[i] then
                            ok = true
                            break
                        end
                    end

                    if not ok then
                        type_err[field] = {expected = rule.one_of, got = type(v)}
                    end
                end


                -- value check
                if rule.value ~= nil and rule.one_of == nil then 
                    if v ~= rule.value then
                        value_err[field] = {expected = rule.value, got = v}
                    end
                elseif rule.value == nil and rule.one_of ~= nil then 
                    local ok = false

                    for _, t in ipairs(rule.one_of) do
                        if v == t then
                            ok = true
                        end
                    end

                    if not ok then
                        type_err[field] = {expected = rule.one_of, got = type(v)}
                    end
                end
            end

            -- value check runs only if no type errors were found
            if type_err[field] == nil then
                if rule.value ~= nil and v ~= rule.value then
                    value_err[field] = {expected = rule.value, got = v}
                end

                if rule.one_of ~= nil then 
                    if type(rule.one_of) ~= "table" then
                        type_err[field] = {reason = "schema_one_of_not_table", expected = "table", got = type(rule.one_of)}
                    else
                        local ok = false

                        for i = 1, #rule.one_of do
                            if v == rule.one_of[i] then
                                ok = true
                                break
                            end
                        end

                        if not ok then
                            value_err[field] = {expected = rule.one_of, got = v}
                        end
                    end
                end
            end   

            if type_err[field] == nil and type(v) == "table" then
                if rule.schema ~= nil then
                    local valid, code = schema_validator(rule.schema, v)

                    if not valid then
                        if code.missing ~= nil then 
                            table.insert(missing, code.missing)
                        end

                        if code.type_err ~= nil then 
                            table.insert(type_err, code.type_err)
                        end

                        if code.value_err ~= nil then
                            table.insert(value_err, code.value_err)
                        end
                    end
                end

            end
        end       
        
        if rule.validate ~= nil then
            if type(rule.validate) ~= "function" then
                value_err[field] = { reason = "schema_validate_not_function", expected = "function", got = type(rule.validate) }
            else
                local ok, err = rule.validate(v, msg)
                if not ok then
                    value_err[field] = { reason = err or "custom_validation_failed", got = v }
                end
                
            end
        end
    end

    local has_errors = (#missing > 0) or next(type_err) ~= nil or next(value_err) ~= nil

    if has_errors then
        return false, {
            reason = "schema_invalid",
            missing = (#missing > 0) and missing or nil,
            type_err = next(type_err) and type_err or nil,
            value_err = next(value_err) and value_err or nil
        } 
    end

    return true, nil
end

return SCHEMAvalidator