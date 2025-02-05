Crushing = {}
Crushing.__index = Crushing

-- DURATIONS Table: {Product Name, Recipe Duration, Ratio}
-- Example: {"gravel", 250, 1} means "gravel" takes 250 ticks and has a ratio of 1:1
local DURATIONS = {
    -- Format: Product = {duration = X, ratio = 1}
    -- Duration: 50
    clay_block = {duration = 50, ratio = 1},
    cactus = {duration = 50, ratio = 1},
    sea_pickle = {duration = 50, ratio = 1},
    sugar_cane = {duration = 50, ratio = 1},
    azure_bluet = {duration = 50, ratio = 1},
    blue_orchid = {duration = 50, ratio = 1},
    fern = {duration = 50, ratio = 1},
    large_fern = {duration = 50, ratio = 1},
    allium = {duration = 50, ratio = 1},
    lily_of_the_valley = {duration = 50, ratio = 1},
    rose_bush = {duration = 50, ratio = 1},
    oxeye_daisy = {duration = 50, ratio = 1},
    poppy = {duration = 50, ratio = 1},
    dandelion = {duration = 50, ratio = 1},
    cornflower = {duration = 50, ratio = 1},
    wither_rose = {duration = 50, ratio = 1},
    orange_tulip = {duration = 50, ratio = 1},
    red_tulip = {duration = 50, ratio = 1},
    white_tulip = {duration = 50, ratio = 1},
    pink_tulip = {duration = 50, ratio = 1},

    -- Duration: 70
    bone_meal = {duration = 70, ratio = 1},
    cocoa_beans = {duration = 70, ratio = 1},
    beetroot = {duration = 70, ratio = 1},
    charcoal = {duration = 70, ratio = 1},
    coal = {duration = 70, ratio = 1},
    lapis_lazuli = {duration = 70, ratio = 1},
    lilac = {duration = 70, ratio = 1},
    peony = {duration = 70, ratio = 1},
    sunflower = {duration = 70, ratio = 1},
    tall_grass = {duration = 70, ratio = 1},

    -- Duration: 100
    wool = {duration = 100, ratio = 1},
    bone = {duration = 100, ratio = 1},
    ink_sack = {duration = 100, ratio = 1},
    coal_ore = {duration = 100, ratio = 1},
    amethyst_cluster = {duration = 100, ratio = 1},
    glowstone = {duration = 100, ratio = 1},
    amethyst_block = {duration = 100, ratio = 1},
    blaze_rod = {duration = 100, ratio = 1},

    -- Duration: 150
    sand_stone = {duration = 150, ratio = 1},
    wheat = {duration = 150, ratio = 1},
    prismarine_crystal = {duration = 150, ratio = 1},
    saddle = {duration = 150, ratio = 1},
    any_horse_armor = {duration = 150, ratio = 1},

    -- Duration: 200
    granite = {duration = 200, ratio = 1},
    terracotta = {duration = 200, ratio = 1},
    andesite = {duration = 200, ratio = 1},

    -- Duration: 250
    calcite = {duration = 250, ratio = 1},
    dripstone_block = {duration = 250, ratio = 1},
    cobblestone = {duration = 250, ratio = 1},
    gravel = {duration = 250, ratio = 1},
    copper_ore = {duration = 250, ratio = 1},
    zinc_ore = {duration = 250, ratio = 1},
    iron_ore = {duration = 250, ratio = 1},
    gold_ore = {duration = 250, ratio = 1},
    redstone_ore = {duration = 250, ratio = 1},
    lapis_ore = {duration = 250, ratio = 1},

    -- Duration: 300
    diorite = {duration = 300, ratio = 1},
    tuff = {duration = 300, ratio = 1},
    diamond_ore = {duration = 300, ratio = 1},
    deepslate_copper_ore = {duration = 300, ratio = 1},
    deepslate_zinc_ore = {duration = 300, ratio = 1},
    deepslate_iron_ore = {duration = 300, ratio = 1},
    deepslate_gold_ore = {duration = 300, ratio = 1},
    deepslate_redstone_ore = {duration = 300, ratio = 1},
    deepslate_lapis_ore = {duration = 300, ratio = 1},
    netherrack = {duration = 300, ratio = 1},

    -- Duration: 400
    any_raw_ore = {duration = 400, ratio = 1},
    emerald_ore = {duration = 400, ratio = 1},
    nether_gold_ore = {duration = 400, ratio = 1},
    nether_quartz_ore = {duration = 400, ratio = 1},

    -- Duration: 450
    deepslate_diamond_ore = {duration = 450, ratio = 1},
    deepslate_emerald_ore = {duration = 450, ratio = 1},

    -- Duration: 500
    obsidian = {duration = 500, ratio = 1}
}


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

function Crushing:idealCrushRate(RPM, Quantity)
    --Function parameter assertion
    assert(type(RPM) == "number", "RPM must be a number input")
    assert(type(Quantity) == "number", "input Quantity must be a number")
    assert(Quantity > 0, "System input quantity may not be nonzero when retreiving output rate")

    local factor, Rate_per_tick = (2 * RPM) / (25 * math.log(Quantity, 2)), 0

    -- Performance extremity bounds chacking
    if factor >= 20 then
        Rate_per_tick = ((2 * Quantity) / 25) * self.size
    elseif factor <= 0.25 then
        Rate_per_tick = (Quantity / 921) * self.size
    else
        Rate_per_tick = (Quantity / ((self.duration - 20) / math.max(0.25,math.min(factor, 20)) + 1)) * self.size
    end

    --Conversion of production Rate into per second
    local Rate_per_second = Rate_per_tick * 20
    return Rate_per_second
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
