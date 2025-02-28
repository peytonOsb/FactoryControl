local Crush = require("Modules.ProductionModule")

local function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

-- print("from left to right please enter the ID of each vault in (#-#-#...) format")
-- local input = read()
-- local VIDs = mysplit(input, "-")
-- print(textutils.serialize(VIDs), #VIDs)

print("please enter the motor IDs in (belt-crush-slave) format")
local input = read()
local MIDs = mysplit(input, "-")
print(textutils.serialize(MIDs))

local Crushing = Crush:ProductionModule(1, "cobblestone",MIDs, nil ) 
Crushing:setCrushRate(4,0.1)