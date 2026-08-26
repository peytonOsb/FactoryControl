local watchdog = {}
watchdog._index = watchdog

function watchdog.new(opts)

    local self_obj = setmetatable(watchdog, {})
    self_obj.mode = (opts and opts.mode) or watchdog.MODE_IND
end

function watchdog:scan()
    local attachments = peripheral.getNames()
    local computers = {}

    --find all computers attached to manager's network
    for _, obj in ipairs(attachments) do
        if peripheral.getType(obj) == "computer" then
            table.insert(computers, obj)
        end
    end

    return computers
end

function watchdog:validateComputers(items, opts)
    if #items == 0 then return nil end 

    local trys = (opts and opts.trys) or 4
    local dispatcher = require("Manager.dispatcher")
    local validatedControllers = {}

    --ping each of the attached computers to ensure properly initiated
    for index, obj in ipairs(items) do
        local temp = peripheral.wrap(obj)
        local Id = temp.getID()

        for i = 1, trys do
            local ping = dispatcher:BuildRequest("inquiry", Id, 0, "Total", nil)
            dispatcher:SendMessage(nil, ping, Id)
            local sender, characteristics, protocol = rednet.receive("response", 1)
            
            --process response from pinged computers
            if characteristics ~= nil then 
                print("Module controller: "..obj.. " has been properly initiated")

                --handle for proper response
                if protocol == "response" and sender == Id then
                    local traits = textutils.unserialiseJSON(characteristics)
                    table.insert(validatedControllers, {items[index], traits.type})
                    print(validatedControllers[index][1], validatedControllers[index][2])
                    break
                else
                    print("received response didn't use proper protocol or was not from right sender")
                end
            else
                print(obj.." is not listening to requests")
            end
        end
    end    

end

return watchdog