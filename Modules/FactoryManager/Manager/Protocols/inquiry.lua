local inquiry = {}

function inquiry:Build( Receiver, Payload, SessionId)
    return {
        type = "inquiry",
        sender = os.getComputerID(),
        receiver = Receiver,
        payload = Payload or {},
        time = os.clock(),
        sessionID = SessionId
    }
end

function inquiry:handle(Message, Response)

    if not Message.payload then
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

    return {
        type = "acknowledge",
        sender = Message.receiver,
        status = "Success",
        receiver = Message.sender,
        payload = Response,
        time = os.clock(),
        sessionID = Message.sessionID
    } 
end

return inquiry