-- load watchdog module
local success, error_or_watchdogMOD = pcall(require, "Modules.Watchdog.object")

if success then print("watchdog module found")
else print("watchdog not found") end



-- load supervisor routine
local success, error_or_supervisorWORK = pcall(require, "Modules.Watchdog.Workers.Supervisor")

if success then print("supervisor thread found")
else print("supervisor thread not found") end

-- load listener routine
local success, error_or_listenerWORK = pcall(require, "Modules.Watchdog.Workers.Listener")

if success then print("Listener thread found")
else print("Listener thread not found") end

-- load edge cases
local success, msgs = pcall(require, "Test_msg") 
if not success then print("couldn't load test messages") end

local opts = {session_id = "nil"}
local watchdog = error_or_watchdogMOD.new(opts)
local listener = error_or_listenerWORK.new(watchdog)

local function msg_handler()    
    for _, message in ipairs(msgs) do
        watchdog:enqueue(message, "9")
    end

    print("messages queued")
end

msg_handler()

print("Queue Size: ", #watchdog.msgQueue)

--local success = 
--if success then print("message enqueued") end

local supervisor = error_or_supervisorWORK.new(watchdog)

local primary = {}

table.insert(primary, function() supervisor:main() end)
table.insert(primary, function() listener:main() end)

parallel.waitForAll(table.unpack(primary))

local f = assert(io.open("FactoryControl/output.txt", "w"))

local string = "===== valid =====\r\n" ..
               textutils.serialise(watchdog.routingQueue) ..
               "\r\n==== invalid ====\r\n" ..
               textutils.serialise(watchdog.invalidMsgs)

f:write(string)
f:close()

