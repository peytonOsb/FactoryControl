local listener = {}
listener.__index = listener

function listener.new(watchdog)
    local self = setmetatable({}, listener)
   
    self.msgQueue = watchdog.msgQueue

    self.listener_id = math.random(100000000)

    self.watchdog = watchdog

    return self
end

function listener:startup()
    self.modems = peripheral.find("modem", rednet.open)

    if self.modems == nil then
        return {err = "undetected_modems",expected = "table",got = type(self.modems)}
    else
        return true
    end
end

function listener:main()
    local success = self:startup()

    if success then
        while true do
            local id, message = rednet.receive(nil, 1)     
            
            if type(message) ~= "nil" then
                print("message found")
                print(textutils.serialise(message))
                self.watchdog:enqueue(message, id)
            end

            os.sleep(0)
        end
    end
end

return listener