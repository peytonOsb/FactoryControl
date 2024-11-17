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

    local Controller = PIDController:newController(0.1,0.1,0.1,args[2],args[3])

    --create the metatable for the electric motor's properties
    local self_obj = setmetatable({}, Motor)
    self_obj.motor = motor
    self_obj.id = peripheral_name
    self_obj.min_speed = args[2]
    self_obj.max_speed = args[3]
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
function Motor:run(set_point,ramped, tol)
    --parameter validation
    assert(type(set_point) == "number", "speed of motors should be set to a number")
    assert(type(ramped) == "boolean", "ramped should be true false value")

    -- Check if the motor whose speed is being altered is a slave
    if self:getStatus() == "slave" then
        error("This motor is a slave and should be set through the master motor")
    end

    --slave retrieval
    local slaves = self:getSlaves()
    self.controller:unwind()

    --variable declaration
    local err
    local TOLERANCE = tol or 0

    --speed determination
    if slaves == nil and not ramped then
        self.motor.setSpeed(set_point)
    elseif slaves == nil and ramped then
        while not (math.abs(self.motor:getSpeed() - set_point) < TOLERANCE) do
            err = set_point - self:getSpeed()
            Cspeed = self.controller:run(err)

            self.motor.setSpeed(Cspeed)
            print(Cspeed)
            os.sleep(0.6)
        end
    elseif slaves ~= nil and not ramped then
        self.motor.setSpeed(set_point)

        for index, data in ipairs(slaves) do
            if slaves[index][2] == false then
                slaves[index][1].motor.setSpeed(set_point)
            else
                slaves[index][1].motor.setSpeed(-set_point)
            end
        end
    elseif slaves ~= nil and ramped then
        while not (math.abs(self.motor:getSpeed() - set_point) < TOLERANCE) do
            err = set_point - self:getSpeed()
            Cspeed = self.controller:run(err)
            
            self.motor.setSpeed(Cspeed)

            for index, data in ipairs(slaves) do

                if slaves[index][2] == false then
                    slaves[index].motor.setSpeed(Cspeed)
                else
                    slaves[index].motor.setSpeed(-Cspeed)
                end
            end    
            
            os.sleep(0.6)
        end
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

function Motor:within(value, desired, TOL)
    if  math.abs(value - desired) < TOL then
        return true
    else
        return false
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
    Motor:run(0,false)
end

--return the motor class
return Motor
