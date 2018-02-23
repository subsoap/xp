ease = require("ease.ease")

local M = {}

M.xp = {}
M.xp_data_filename = "/xp/blank_data.lua"
M.xp_data = {}
M.initiated = false
M.verbose = false

local function catch(what)
	return what[1]
end

local function try(what)
	status, result = pcall(what[1])
	if not status then
		what[2](result)
	end
	return result
end

function M.node_exists(node)
	local exists = true
	try {
		function()
			gui.get_node(node)
		end,
		catch {
			function(error)
				exists = false
			end
		}
	}
	return exists
end

function M.init()
	M.xp_data = assert(loadstring(sys.load_resource(M.xp_data_filename)))()
	M.initiated = true
	if M.verbose == true then print("XP: Initialized") end
end

function M.update_xp(dt)
	for k,v in pairs(M.xp) do
		v.time = v.time + dt
	end
end

function M.update(dt)
	M.update_xp(dt)
end

function M.get_data()
end

function M.load_data()
end

local function setup_node(node_name)
	if node_name ~= nil then
		assert(M.node_exists(node_name), "XP: node_text_current_xp must be a node that exists")
		return gui.get_node(node_name)	
	else
		return nil
	end	
end

-- If you pass in data then it will overwrite all values listed within
function M.create_id(id, label, data)
	assert(M.xp[id] == nil, "XP: You cannot have duplicate XP IDs")
	assert(M.xp_data[label] ~= nil, "XP: create_id requires a valid label found in your xp data template")
	local xp = {}

	xp.id = id
	
	xp.level = M.xp_data[label].level or 1
	xp.xp_needed = M.xp_data[label].xp_needed or 0
	xp.xp_total = M.xp_data[label].total_xp or 0
	xp.xp_max = 0
	xp.xp_accumulative = 0
	xp.current_xp = 0
	xp.current_visible_xp = 0
	
	xp.style = M.xp_data[label].style or 1
	xp.loop = M.xp_data[label].loop or false
	xp.loop_level = M.xp_data[label].loop_level or 100
	xp.loop_reset_xp_amounts = M.xp_data[label].loop_reset_xp_amounts or false
	xp.loops_done = M.xp_data[label].loops_done or 0
	xp.max_level = M.xp_data[label].max_level or 100
	xp.limit_by_max_level = M.xp_data[label].limit_by_max_level or false

	if data ~= nil then
		for k,v in pairs(data) do
			xp[k] = v
			if k == "node_text_current_xp" or k == "node_text_max_xp" or k == "node_clipper" then
				xp[k] = setup_node(v)
			end
		end
	end

	if xp.node_clipper ~= nil then
		xp.node_clipper_size = gui.get_size(xp.node_clipper)
		xp.node_clipper_width = xp.node_clipper_size.x		
	end
	
	xp.formulas = M.xp_data[label].formulas or {}
	xp.xp_amounts = M.xp_data[label].xp_amounts or {}
	
	xp.time = 0
	xp.easing_duration = 0.75
	xp.easing_range_initial = 0
	xp.easing_range_total = math.min(xp.current_xp / M.get_level_max_xp(xp) * 100, 100)
	xp.easing_range_total_new = xp.easing_range_total - xp.easing_range_initial
	xp.easing = ease.out_cubic(math.min(xp.time, xp.easing_duration), xp.easing_duration, 0, xp.easing_range_total_new ) + xp.easing_range_initial

	xp.node_text_current_xp = setup_node(M.xp_data[label].node_text_current_xp)
	xp.node_text_max_xp = setup_node(M.xp_data[label].node_text_max_xp)
	xp.node_clipper = setup_node(M.xp_data[label].node_clipper)


	if xp.node_clipper ~= nil then
		M.scale_gui_bar_clipper_size_x(xp.xp_clipper_node, xp.easing / 100, xp.xp_clipper_size)
	end


	
	M.xp[id] = xp
	return M.xp[id]
end

function M.get_level_max_xp(xp)
	if xp.style == 1 then -- look up table of pre made values
		if #xp.xp_amounts >= xp.level then
			return xp.xp_amounts[xp.level]
		else
			return xp.xp_amounts[#xp.xp_amounts]
		end
	elseif xp.style == 2 then -- xp formula function
		local counter = 0
		for k,v in ipairs(xp.formulas) do
			counter = counter + 1
			if xp.level <= v.level then
				local level = xp.level
				return v.formula(level)
			end
			if counter == #xp.formulas then
				local level = xp.level
				return v.formula(level)			
			end
		end
	end
end

function M.delete_id(id)
end

function M.add_xp(id, amount)
	M.xp[id].time = 0
end

function M.set_total_xp(id, amount)
end

function M.set_level(id, level)
end

function M.level_up()
end

function M.update_xp()
end

-- Percent is 0-1
function M.scale_gui_bar_clipper_size_x(node, percent, original_size)
	assert(percent <= 1 and percent >= 0, "XP: scale_gui_bar_clipper_size_x requires a percent in the range of 0-1")
	percent = math.max(0, percent)
	percent = math.min(100, percent)
	gui.set_size(node, vmath.vector3(original_size.x * percent, original_size.y, original_size.z))	
end

function M.scale_gui_bar_clipper_size_y(node, percent, original_size)
	M.scale_gui_bar_clipper_size_x(node, percent, original_size)
end

-- this makes the text of the visible current xp go up smoothly
-- you need fixed width bitmap fonts for counters if you don't want them to visibly jump around as they increase
function M.update_current_xp_text(node, xp_visible, current_xp, max_xp, ratio, dt)
	xp_visible = M.get_current_xp_text(xp_visible, current_xp, max_xp, ratio, dt)
	gui.set_text(node, xp_visible)
	return xp_visible
end

function M.get_current_xp_text(xp_visible, current_xp, max_xp, ratio, dt)
	dt = dt or 1
	assert(ratio > 0 and ratio <= 1, "XP: get_current_xp_text requires a ratio > 0 and <= 1")
	ratio = ratio or 0.14
	if math.abs(xp_visible - current_xp) <= 1 then
		xp_visible = current_xp
	else
		xp_visible = math.floor(xp_visible + (current_xp - xp_visible) * ratio * dt * 30)
	end
	return math.min(xp_visible, max_xp)
end

return M