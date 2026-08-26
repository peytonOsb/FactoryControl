Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher:ReadFile(Path)
    assert(type(Path) == "string", "provided file pathway should be of type string")
    local file = fs.open(Path, "r")
    local contents = file:read()
    print(contents)
end

--format manager requests within the framework of messaging protocols
function Dispatcher:BuildRequest(Type, Receiver, sessionID, payload, Pathway)
    local Messages = {}
    local Protocols = fs.list("FactoryControl/Modules/FactoryManager/Manager/Protocols")
    
    -- Dynamically load all protocols into Messages table
    for index, Protocol in ipairs(Protocols) do
        if Protocol:match("%.lua$") then
            local name = Protocol:gsub("%.lua$", "")
            Messages[name] = require(string.format("Manager.Protocols.%s", name))
        end
    end
    
    -- Build the request using the correct protocol
    if not Messages[Type] then
        error("Protocol not found: " .. tostring(Type))
    end

    if Type == "inquiry" then
        return Messages[Type]:Build(Receiver, {Message = payload}, sessionID)
    elseif Type == "transfer" then
        return Message[Type]:Build(Receiver, {Message = payload}, sessionID, Pathway)
    end
end



--valid Protocols include: Inquiry, transfer
function Dispatcher:SendMessage(Manager, Message, Receiver)
    local sides = {"left", "right", "top", "bottom", "front", "back"}

    --open the computer's network for communication
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            rednet.open(side)
            break
        end
    end

    --send message to required equipment
    if type(Receiver) == "table" then
        for _, value in ipairs(Receiver) do
            rednet.send(value, Message)
        end
    else
        if Receiver == "All" then
            rednet.broadcast(Message)
        else
            assert(type(Receiver) == "number", string.format("The supplied receiver %s was not a number", Receiver))
            rednet.send(Receiver, Message)
        end
    end
end

return Dispatcher