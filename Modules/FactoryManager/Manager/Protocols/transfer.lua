local transfer = {}

function transfer:Build(Receiver, Payload, Session, Pathway)
    return {
    type = "transfer",
    sender = os.getComputerID(),
    receiver = Receiver,
    sessionID = Session,
    payload = {
        path = Pathway,          
        contents = Payload, 
        mode = "w"                        
    }
    }

end

function transfer:handle(Message)
    local payload = Message.payload

    --
    if not (payload.path and payload.contents) then
        return {
        type = "acknowledge",
        sender = Message.receiver,
        receiver = Message.sender,
        status = "error",
        payload = {Message = "Could not verify payload"},
        time = os.clock(),
        sessionID = Message.sessionID
        }
    end

    --find or make the reference directory
    local dir = fs.getDir(payload.path)
    if not dir then 
        fs.makeDir(payload.path)
    end

    --open file
    local file = fs.open(Message.payload.path, Message.payload.mode)
    if not file then
        return {
            type = "acknowledge",
            sender = Message.receiver,
            status = "error",
            payload = {Message = "Could not build file"},
            receiver = Message.sender,
            time = os.clock(),
            sessionID = Message.sessionID
        }
    end

    file.write(Message.payload[Message])
    file.close()

    return {
        type = "acknowledge",
        sender = Message.receiver,
        status = "Success",
        receiver = Message.sender,
        time = os.clock(),
        sessionID = Message.sessionID
    } 
end

return transfer