local moduleName = ...
local M = {}
_G[moduleName] = M
local Si7021_ADDR = 0x11
local CMD_MEASURE_HUMIDITY_HOLD = 0xE5
local CMD_MEASURE_HUMIDITY_NO_HOLD = 0xF5
local CMD_MEASURE_TEMPERATURE_HOLD = 0xE3
local CMD_MEASURE_TEMPERATURE_NO_HOLD = 0xF3
local t,h
local init = false
local id = 0
local function twoCompl(value)
 if value > 32767 then value = -(65535 - value + 1)
 end
 return value
end
local function read_data(ADDR, commands, length)
  i2c.start(id)
  i2c.address(id, ADDR, i2c.TRANSMITTER)
  i2c.write(id, commands)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, ADDR,i2c.RECEIVER)
  tmr.delay(20000)
  c = i2c.read(id, length)
  i2c.stop(id)
  return c
end
function M.init(sda, scl)
  i2c.setup(id, sda, scl, i2c.SLOW)
  init = true
end
local function read_humi()
  dataH = read_data(Si7021_ADDR, CMD_MEASURE_HUMIDITY_HOLD, 2)
  UH = string.byte(dataH, 1) * 256 + string.byte(dataH, 2)
  h = ((UH*12500+65536/2)/65536 - 600)
  return(h)
end
local function read_temp()
  dataT = read_data(Si7021_ADDR, CMD_MEASURE_TEMPERATURE_HOLD, 2)
  UT = string.byte(dataT, 1) * 256 + string.byte(dataT, 2)
  t = ((UT*17572+65536/2)/65536 - 4685)
  return(t)
end
function M.read()
  if (not init) then
     print("init() must be called before read.")
  else
	 read_humi()
	 read_temp()
  end
end;
function M.getHumidity()
  return h
end
function M.getTemperature()
  return t
end
return M
