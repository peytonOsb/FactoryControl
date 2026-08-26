local sides = {"left", "right", "top", "bottom", "front", "back"}

--open the computer's network for communication
for _, side in ipairs(sides) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
        break
    end
end

local status = textutils.serialiseJSON({type = "crusher", Status = "inactive", size = 4})

while true do
    local sender, message, protocol = rednet.receive(nil, 2)
    
    if message ~= nil then
        print("inquiry received, Responding....")
        rednet.send(sender, status, "response")
    else
        print("nothing received")
    end
end