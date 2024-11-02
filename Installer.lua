-- git hub file location setting
local Factory_class = "https://raw.githubusercontent.com/peytonOsb/FactoryControl/main/Factory_classes.lua"
local Module_tester = "https://raw.githubusercontent.com/peytonOsb/FactoryControl/main/ModuleTester.lua"
local PIDController = "https://raw.githubusercontent.com/peytonOsb/FactoryControl/main/PIDController.lua"
local MotorController = "https://raw.githubusercontent.com/peytonOsb/FactoryControl/main/motor_controller.lua"
local test = "https://raw.githubusercontent.com/peytonOsb/FactoryControl/main/test.lua"

--read variables for each of the files we have to recieve
local FC, MT, PID, MC, T
local FCFile, MTFile, PIDFile, MCFile, TFile

fs.makeDir("lib")

--file retrieval for factory classes
FC = http.get(Factory_class)
FCFile = FC.readAll()

local file1 = fs.open("lib/Factory_class", "w")
file1.write(FCFile)
file1.close()

--file retrieval for module tester
MT = http.get(Module_tester)
MTFile = MT.readAll()

local file1 = fs.open("lib/Module_Tester", "w")
file1.write(MTFile)
file1.close()

--file retrieval for PID controller
PID = http.get(PIDController)
PIDFile = PID.readAll()

local file1 = fs.open("lib/PIDController", "w")
file1.write(PIDFile)
file1.close()

--file retrieval for motor controller class
MC = http.get(MotorController)
MCFile = MC.readAll()

local file1 = fs.open("lib/motorCont", "w")
file1.write(MCFile)
file1.close()

--file retrieval for motor controller class
T = http.get(test)
MCFile = T.readAll()

local file1 = fs.open("test", "w")
file1.write(TFile)
file1.close()
