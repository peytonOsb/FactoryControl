--Define the motor class
Motor = {}
Motor.__index = Motor

--contructor for a new electric motor
function Motor:new(id,max,min)
    --input validation for electric_motor
    assert(type(id) == "string", "the id: "..id.. "should be a string")
    assert(type(max) == "number", "the maximum speed must be a number")
    assert(type(min) == "number", "the minimum speed must be a number")

    --finding the physical electric motor
    local peripheral_name = "electric_motor_" .. tostring(id)
    local motor = peripheral.wrap(peripheral_name)

    --validate that the motor was found
    if not motor then
        error("the motor of name: "..peripheral_name.." could not be found")
    end

    if type(motor.setSpeed) ~= "function" then
        error("the found peripheral was not an electric motor")
    end

    --create a new pid controller specific to the electric motor instance
    local PIDController = require("PIDController")
    local Controller = PIDController:newController(0.1,0.1,0.1,max,min)

    --create the metatable for the electric motor's properties
    local self_obj = setmetatable({}, Motor)
    self_obj.motor = motor
    self_obj.id = peripheral_name
    self_obj.min_speed = min
    self_obj.max_speed = max
    self_obj.controller = Controller
    self_obj.status = nil

    --return the motor's instance
    return self_obj
end

--sets another motor as a slave to this motor
function Motor:setSlave(...)  
    local args = {...}
    --verify input perameters
    assert(type(args[1]) == "table","the first input must be a motor object")
    assert(type(args[2]) == "boolean" or "nil","the second input must be a boolean declaring whether the follow is inverted")

    --append the motor to the list of the master's slaves
    table.insert(self.slaves, args[1])
end --unimplemented

--sets another motor as a slave to this motor
function Motor:getSlaves() 
    local slaves = {} 
    for i = 1,#self.slaves do
        table.insert(slaves,i)
    end

    return slaves
end --unimplemented

-- Helper function for setting the motor and all slaves' speeds
function Motor:run(set_point)
    self.motor:setSpeed(set_point)
end

-- helper function for retrieving the motors speed
function Motor:getSpeed()
    return self.motor.getSpeed()
end

-- return the status of the current motor
function Motor:getStatus()
    return self.motor.status
end

-- return the id of the current motor
function Motor:getId()
    return self.motor.id
end

--helper function for stopping the motor
function Motor:stop()
    Motor:run(0)
end

--return the motor class
return Motor