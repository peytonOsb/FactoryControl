--Define the motor class
Motor = {}
Motor.__index = Motor

--contructor for a new electric motor
function Motor:new(...)
    local args = {...}

    --{id, max, min, P, I, D}
    --input validation for electric_motor
    assert(type(args[1]) == "string", "the id: "..args[1].. "should be a string")
    assert(type(args[2]) == "number", "the maximum speed must be a number")
    assert(type(args[3]) == "number", "the minimum speed must be a number")

    --optional input validation
    if #args > 3 then
        assert(type(args[4]) == "number" or type(args[4]) == nil, "the minimum speed must be a number")
        assert(type(args[5]) == "number" or type(args[5]) == nil, "the minimum speed must be a number")
        assert(type(args[6]) == "number" or type(args[6]) == nil, "the minimum speed must be a number")
    end

    local peripheral_name = "electric_motor_" .. tostring(args[1])
    --finding the physical electric motor

    local motor = peripheral.wrap(peripheral_name)

    --validate that the motor was found
    if not motor then
        error("the motor of name: "..peripheral_name.." could not be found")
    end

    if type(motor.setSpeed) ~= "function" then
        error("the found peripheral was not an electric motor")
    end

    --create a new pid controller specific to the electric motor instance
    local PIDController = require("lib/PIDController")

    if #args > 3 then
        local Controller = PIDController:newController(args[4],args[5],args[6],args[2],args[3])
    else
        local Controller = PIDController:newController(0.1,0.1,0.1,args[2],args[3])
    end

    --min max sorting allowing input of min and max in any order
    if args[3] > args[2] then
        local max = args[3]
        args[3] = args[2]
        args[2] = max
    end
        
    --create the metatable for the electric motor's properties
    local self_obj = setmetatable({}, Motor)
    self_obj.motor = motor
    self_obj.id = peripheral_name
    self_obj.max_speed = args[2]
    self_obj.min_speed = args[3]
    self_obj.controller = Controller
    self_obj.status = nil

    --return the motor's instance
    return self_obj
end

--sets another motor as a slave to this motor
function Motor:setSlave(...)  
    local args = {...}
    -- Verify input parameters
    assert(type(args[1]) == "table", "the first input must be a motor object")
    assert(type(args[2]) == "boolean" or args[2] == nil, "the second input must be a boolean declaring whether the follow is inverted")

    -- Initialize self.slaves if it's nil
    self.slaves = self.slaves or {}
    
    -- Append the slave motor to the master's list of slaves
    table.insert(self.slaves, {args[1], args[2]})
    args[1].status = "slave"
    self.status = "master"
end


--slave removal function for motors
function Motor:removeSlave(...)
    local args = {...}

    -- Ensure the input parameters are either tables or strings
    for _, motor in ipairs(args) do
        assert(type(motor) == "table" or type(motor) == "string", "You must either input the motor's ID or the motor object")
    end

    -- Loop over each motor argument to remove matching slaves
    for _, motor in ipairs(args) do
        if type(motor) == "string" then
            for index, slave_data in ipairs(self.slaves)do 
                if slave_data[1]:getId() == "electric_motor_" .. motor then
                    table.remove(self.slaves, index)
                end
            end
        elseif type(motor) == "table" then
            for index, slave_data in ipairs(self.slaves)do 
                if motor:getId() == slave_data[1]:getId() then
                    table.remove(self.slaves, index)
                end
            end
        end
    end
end

-- Helper function for setting the motor and all slaves' speeds
function Motor:run(set_point)
    local clamped_speed
    assert(type(set_point) == "number", "The speed a motor needs to be set to should be a number")

    -- Check if the motor whose speed is being altered is a slave
    if self:getStatus() == "slave" then
        error("This motor is a slave and should be set through the master motor")
    end

    --parameter clamping for speed setting
    if set_point < self.min_speed then
        clamped_speed = self.min_speed
    elseif set_point > self.max_speed then
       clamped_speed = self.max_speed 
    else
        clamped_speed = set_point
    end

    -- Set the motor's speed as well as all its slaves' speeds, if any
    if self:getStatus() == "master" then
        --set speed of both the "master" motor and slav motors' speeds
        self.motor.setSpeed(clamped_speed)
        for index, slave_data in ipairs(self.slaves) do
            if slave_data[2] == true then
                slave_data[1].motor.setSpeed(-clamped_speed)
            else
                slave_data[1].motor.setSpeed(clamped_speed)
            end
        end        
    elseif self:getStatus() == nil then
        self.motor.setSpeed(clamped_speed)
    end
end

--helper function for retrieving the set of slaves found within this motor
function Motor:getSlaves() 
    if self:getStatus() == "master" then
        return self.slaves
    else
        return nil
    end
end 

--helper function for retrieving the motors speed
function Motor:getSpeed()
    return self.motor.getSpeed()
end

--helper function for retrieving the status of the current motor
function Motor:getStatus()
    return self.status
end

-- helper function for retrieving the id of the current motor
function Motor:getId()
    return self.id
end

--helper function for stopping the motor
function Motor:stop()
    Motor:run(0)
end

--return the motor class
return Motor
