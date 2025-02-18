local Crush = require("Mod")

print("please enter each motor ID pressing enter after each one: ")
local IDs = {read(),read(),read()}

local Crusher = Crush:Module(1, "Cobblestone", IDs)