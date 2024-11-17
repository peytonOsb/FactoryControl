PID = {}
PID.__index = PID

--PID constructor for new instances
function PID:newController(gain, compensation, dampening, max, min)
  --input handeling
  assert(type(gain) == "number","the gain value must be a number")
  assert(type(compensation) == "number","the compensation value must be a number")
  assert(type(dampening) == "number","the dampening value must be a number")
  assert(type(max) == "number","the max value must  be a number")
  assert(type(min) == "number","the min value must be a number")

  --metatable creatiion
  local self_obj = setmetatable({},PID)

  --controller property assigment
  self_obj.gain = gain
  self_obj.compensation = compensation
  self_obj.dampening = dampening
  self_obj.max = max
  self_obj.min = min

  --value creation for controller
  self_obj.prev_err = 0
  self_obj.prev_integral = 0
  self_obj.prev_derivative = 0

  --object return for instantiation
  return self_obj
end

function PID:run(err)
  --setpoint creation
  local error = err

  --derivative coefficient calculation
  local derivative = error - self.prev_err
  self.prev_err = error

  --integral coefficient calculation
  local integral = self.prev_integral + error
  self.prev_integral = integral

  --output determination and clamping
  local output = error * self.gain + integral * self.compensation + derivative * self.dampening
  local clamped_output = math.max(self.min, math.min(self.max, output))

  --output return for system adjustment
  return clamped_output
end

function PID:unwind()
  self.prev_err = 0
  self.prev_integral = 0
end


return PID