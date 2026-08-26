local helpers = {}
helpers.__index = helpers

function helpers:Response(Type, Subrequest)
    local status

    if self:getRate() ~= 0 then
        status = "active"
    else
        status = "inactive"
    end

    if Type == "inquiry" then
        if Subrequest == "total" then
            local Message = {status = status, task = self.task, progress = nil, rate = nil, uptime = nil, lastUpdate = os.clock(), priority = nil, load = nil, size = self.size, type = self.type}
            return textutils.serialiseJSON(Message)
        else
            local Message = {status = status, uptime = nil, priority = nil, load = nil, self.size, self.type}
            return textutils.serialiseJSON(Message)
        end
    elseif Type == "request" then
        if Subrequest == "main" then
            self:main_loop()
        elseif Subrequest == "standby" then
            self:standby_loop()
        else
            print("could not understand subrequest in this context")
        end
    else
        print("unsupported Request type")
    end
end

function helpers:standby_loop()
    local sides = {"left", "right", "top", "bottom", "front", "back"}

    --open the computer's network for communication
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            rednet.open(side)
            break
        end
    end

    while true do
        local sender, message, protocol = rednet.receive(nil, 2)
        
        if message ~= nil then
            print("inquiry received, Responding....")
            rednet.send(sender, self:Response(protocol, message), "response")
        else
            print("nothing received")
        end
    end
end

function helpers:getOutput(quantity, rpm)
    local denominator = math.max(0.25, math.min((25 * math.log(quantity, 2)) / (2 * rpm), 20))
    return ((quantity / (230 / denominator)) + 1) * 20
end

function helpers:getMaxOutput()
    return self:getOutput(64, 256) * self.size
end

function helpers:getElectricityUsage()
    local belt_speed = self.belt:getSpeed()
    local crusher_speed = self.crush:getSpeed()
    return (0.9 * belt_speed) + 2 * (0.9 * crusher_speed)
end

function helpers:setCrushingSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0,"Crushers must run at a speed greater than zero")
    self.crush:run(Speed)
end

function helpers:getSize()
    return self.size
end

function helpers:setInputSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0, "Belt speed must be a non-negative number")
    self.belt:run(Speed)
end

function helpers:getStorage()
    return self.vaults
end

function helpers:getRate()
    return self.crush:getSpeed()
end

return helpers