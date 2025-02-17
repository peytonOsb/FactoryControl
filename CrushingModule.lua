Crushing = {}
Crushing.__index = Crushing

function Crushing:Module(size, Product, motors)
    --motors syntax {Belt, Crusher, Crusher_slave}
    --Parameter assertion
    assert(type(size) == "number","size must be of type number")
    assert(type(motors[1]) == "string","motor ID must be of type string")
    assert(type(motors[2]) == "string","motor ID must be of type string")
    assert(type(motors[3]) == "string","motor ID must be of type string")
    assert(type(Product) == "string","Product must be of type string")
    assert(#motors == 3, "motors table must contain exactly three motor IDs")

    --assert that the program could find the motor_controller class
    local mc = require("LIB/motor_controller")
    assert(type(mc.getId) == "function","Could not correctly find the motor_controller file")
    
    --motor initialization
    local belt = mc.new(motors[1], 256, 0) 
    local crusher = mc.new(motors[2], 256, 0) 
    local slave = mc.new(motors[3], 256, 0) 
    crusher:setSlave(slave)
    
    --object data setting
    local self_obj = setmetatable({}, Crushing)
    self_obj.size = size
    self_obj.duration = DURATIONS[Product].duration 
    self_obj.ratio = DURATIONS[Product].ratio
    self_obj.motors = {belt = belt, crusher = crusher, slave = slave}
    return self_obj
end

function Crushing:getElectricityUsage()
    local belt_speed = self.motors.belt:getSpeed()
    local crusher_speed = self.motors.crusher:getSpeed()
    return (0.9 * belt_speed) + 2 * (0.9 * crusher_speed)
end

function Crushing:setCrushingSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0,"Crushers must run at a speed greater than zero")
    self.motors.crusher:run(Speed)
end

function Crushing:setInputSpeed(Speed)
    assert(type(Speed) == "number" and Speed >= 0, "Belt speed must be a non-negative number")
    self.motors.belt:run(Speed)
end
