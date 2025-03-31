--Define the message Class
Message = {}
Message.__index = Message

local Structure = {
                    ["Message Type"] = nil,
                    ["Sender"] = nil,
                    ["TimeStamp"] = nil,
                    ["Task"] = {
                                ["Details"] = nil,
                                ["Materials"] = nil,
                                ["Rate"] = nil,
                                ["Quantity"] = nil
                    }
}

function Message:Format(Protocol, SenderID, TaskType, Material, Rate, Quantity)
    local newMessage = {}
    for k,v in ipairs(Structure) do
        newMessage[k] = v
    end

    Message["Message Type"] = Protocol
    Message["Sender"] = SenderID
    Message["TimeStamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    Message["Task"]["Details"] = TaskType
    Message["Task"]["Materials"] = Material
    Message["Task"]["Rate"] = Rate
    Message["Task"]["Quantity"] = Quantity

    return newMessage
end

return Message 