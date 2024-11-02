Factory = {}
Factory.__index = Factory

--contructor for a new electric motor
function Factory:new_gravel(id, belt_motor, crusher_master, crusher_slave)
    --input validation for gravel crushing module
    assert(type(id) == "string", "the id: "..id.. "should be a string")
    assert(type(belt_motor) == "number", "this parameter must be a motor object")
    assert(type(crusher_master) == "table", "this parameter must be a motor object")
    assert(type(crusher_slave) == "table", "this parameter must be a motor object")

    local motor_controller = require("motor_controller.lua")

    if type(motor_controller.run) ~= "function" then
        error("motor control class not found")
    end

    --assigning id to the given module
    local module_name = "Gravel_module" .. tostring(id)

    local belt = belt_motor
    local crusher = crusher_master
    local crusher_slave = crusher_slave

    crusher:setSlave(crusher_slave)

    --create the metatable for the modules properties
    local self_obj = setmetatable({}, Factory)
    self_obj.max_production_rate = 100
    self_obj.belt_motor = belt
    self_obj.crusher_master = crusher
    self_obj.crusher_slave = crusher_slave
    
    --return the modules instance
    return self_obj
end

function Factory:set_gravel_speed(Rate)
    -- determine the speed of the motors based on desired rate and some measured function of rate
    local crusher_speed = Rate * 2
    local belt_speed = Rate * 4

    --set motors to the desired speed assuming speed is no greater than the max output of the motors
    if crusher_speed <= self.crusher_master.max_speed then
        self.crusher_master:run(crusher_speed)
    else
        print("speed too high for motors")
    end

    if belt_speed <= self.belt_motor.max_speed then
        self.belt_motor:run(crusher_speed)
    else
        print("speed too high for motors")
    end

end

return Factory