-- :jub:

util.require_natives("1627063482")

local root = menu.my_root()

local fpCarFov = 80
local fpFootFov = 90
local tpCarFov = 80
local tpFootFov = 60
local lerp_duration = 0.5


local fpCarFovSlider = root:slider("First Person Vehicle FOV", {"fpVehicleFov"}, "Changes first person fov in vehicles", 1, 360, 80, 1, function(val)
  fpCarFov = val
  lerp_fov(val, lerp_duration, "fpinveh")
end)
local fpFootFovSlider = root:slider("First Person On Foot FOV", {"fpFootFov"}, "Changes first person fov on foot", 1, 360, 90, 1, function(val)
  fpFootFov = val
  lerp_fov(val, lerp_duration, "fponfoot")
end)
local tpCarFovSlider = root:slider("Third Person Vehicle FOV", {"tpVehicleFov"}, "Changes third person fov in vehicles", 1, 360, 80, 1, function(val)
  tpCarFov = val
  lerp_fov(val, lerp_duration, "tpinveh")
end)
local tpFootFovSlider = root:slider("Third Person On Foot FOV", {"tpFootFov"}, "Changes third person fov on foot", 1, 360, 60, 1, function(val)
  tpFootFov = val
  lerp_fov(val, lerp_duration, "tponfoot")
end)
local lerpDurationSlider = root:text_input("Interpolation Speed", {"interpolationSpeed"}, "Changes the speed at which your fov will interpolate",  function(on_input)
  lerp_duration = on_input
end, "0.5")

function lerp_fov(target_value, duration, fovType)
  local start_time = os.clock()
  local start_value = menu.get_value(menu.ref_by_command_name("fov" .. fovType))
  local end_time = start_time + duration
  
  while os.clock() < end_time do
    local t = (os.clock() - start_time) / duration
    local new_value = start_value + (target_value - start_value) * t * t * (3 - 2 * t)
    menu.set_value(menu.ref_by_command_name("fov" .. fovType), math.floor(new_value))
    util.yield()
  end
  
  menu.set_value(menu.ref_by_command_name("fov" .. fovType), target_value)
end


local wasInVehicle = false

util.create_tick_handler(function()
  local isInVehicle = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false)
  if wasInVehicle and not isInVehicle then
    -- leaves vehicle
    if not conditionsChanged then
      menu.set_value(menu.ref_by_command_name("fovtponfoot"), tpCarFov)
      menu.set_value(menu.ref_by_command_name("fovfponfoot"), fpCarFov)
      lerp_fov(tpFootFov, lerp_duration, "tponfoot")
      lerp_fov(fpFootFov, lerp_duration, "fponfoot")
        conditionsChanged = true  -- set flag to true to prevent repeated execution
    end
elseif not wasInVehicle and isInVehicle then
    -- enters vehicle
    if not conditionsChanged then
      menu.set_value(menu.ref_by_command_name("fovtpinveh"), tpFootFov)
      menu.set_value(menu.ref_by_command_name("fovfpinveh"), fpFootFov)
      lerp_fov(tpCarFov, lerp_duration, "tpinveh")
      lerp_fov(fpCarFov, lerp_duration, "fpinveh")
      conditionsChanged = true  -- set flag to true to prevent repeated execution
    end
else
    conditionsChanged = false  -- reset flag when the conditions are the same as the previous tick
end

wasInVehicle = isInVehicle  -- update the previous state

end)

util.keep_running()