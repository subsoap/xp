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
		M.xp[v.id].easing_timer = M.xp[v.id].easing_timer + dt
		M.xp[v.id].easing = ease.out_cubic(math.min(M.xp[v.id].easing_timer, M.xp[v.id].easing_duration), M.xp[v.id].easing_duration, 0, M.xp[v.id].easing_range_total_new) + M.xp[v.id].easing_range_initial

		if M.xp[v.id].easing > 100 then M.xp[v.id].easing = 100 end
		if (M.xp[v.id].easing == M.xp[v.id].easing_range_total and M.xp[v.id].xp_current >= M.xp[v.id].xp_max) or M.xp[v.id].xp_current >= M.xp[v.id].xp_max and M.xp[v.id].easing >= 100 then
			print("Level Up!")
			M.level_up(v.id)
		elseif (M.xp[v.id].easing ~= M.xp[v.id].easing_range_total) then
			if M.xp[v.id].node_clipper ~= nil then
				M.scale_gui_bar_clipper_size_x(M.xp[v.id].node_clipper, M.xp[v.id].easing / 100, M.xp[v.id].node_clipper_size)
			end			
		end
		if M.xp[v.id].node_text_xp_current ~= nil then
			M.xp[v.id].xp_current_visible = math.min(M.xp[v.id].xp_max, xp.update_xp_current_text(M.xp[v.id].node_text_xp_current, M.xp[v.id].xp_current_visible, M.xp[v.id].xp_current, M.xp[v.id].xp_max, 0.25, dt))
			gui.set_text(M.xp[v.id].node_text_xp_current, M.xp[v.id].xp_current_visible)
		end
		if M.xp[v.id].node_text_max_xp ~= nil then
			gui.set_text(M.xp[v.id].node_text_max_xp, "/" .. M.get_level_max_xp(M.xp[v.id]))
		end
		if M.xp[v.id].node_current_level_text ~= nil then
			gui.set_text(M.xp[v.id].node_current_level_text, M.xp[v.id].level)
		end			
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
		assert(M.node_exists(node_name), "XP: node_text_xp_current must be a node that exists")
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

	xp.style = M.xp_data[label].style or 1
	xp.loop = M.xp_data[label].loop or false
	xp.loop_level = M.xp_data[label].loop_level or 100
	xp.loop_reset_xp_amounts = M.xp_data[label].loop_reset_xp_amounts or false
	xp.loops_done = M.xp_data[label].loops_done or 0
	xp.max_level = M.xp_data[label].max_level or 100
	xp.limit_by_max_level = M.xp_data[label].limit_by_max_level or false

	xp.formulas = M.xp_data[label].formulas or {}
	xp.xp_amounts = M.xp_data[label].xp_amounts or {}

	xp.level = M.xp_data[label].level or 1
	xp.xp_needed = M.xp_data[label].xp_needed or 100
	xp.xp_total = M.xp_data[label].total_xp or 0
	xp.xp_max = M.get_level_max_xp(xp)
	xp.xp_accumulative = 0
	xp.xp_current = 0
	xp.xp_current_visible = 0



	if data ~= nil then
		for k,v in pairs(data) do
			xp[k] = v
			-- this should be from a table or something
			if k == "node_text_xp_current" or k == "node_text_max_xp" or k == "node_clipper" or k == "node_current_level_text" then
				xp[k] = setup_node(v)
			end
		end
	end

	xp.easing_timer = 0
	xp.easing_duration = 0.75
	xp.easing_range_initial = 0
	xp.easing_range_total = math.min(xp.xp_current / M.get_level_max_xp(xp) * 100, 100)
	xp.easing_range_total_new = xp.easing_range_total - xp.easing_range_initial
	xp.easing = ease.out_cubic(math.min(xp.easing_timer, xp.easing_duration), xp.easing_duration, 0, xp.easing_range_total_new ) + xp.easing_range_initial

	xp.node_text_xp_current = xp.node_text_xp_current or setup_node(M.xp_data[label].node_text_xp_current)
	xp.node_text_max_xp = xp.node_text_max_xp or setup_node(M.xp_data[label].node_text_max_xp)
	xp.node_clipper = xp.node_clipper or setup_node(M.xp_data[label].node_clipper)
	xp.node_current_level_text = xp.node_current_level_text or setup_node(M.xp_data[label].node_current_level_text)
	
	if xp.node_clipper ~= nil then
		xp.node_clipper_size = gui.get_size(xp.node_clipper)
		xp.node_clipper_width = xp.node_clipper_size.x		
	end

	if xp.node_clipper ~= nil then
		M.scale_gui_bar_clipper_size_x(xp.node_clipper, xp.easing / 100, xp.node_clipper_size)
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

function M.set_total_xp(id, amount)
end

function M.set_level(id, level)
end

function M.level_up(id, level_up_amount)
	--print(id, level_up_amount)
	--pprint(M.xp[id])
	level_up_amount = level_up_amount or 1
	M.xp[id].level = M.xp[id].level + level_up_amount
	M.xp[id].easing_timer = 0
	M.xp[id].xp_current = M.xp[id].xp_current - M.xp[id].xp_max
	M.xp[id].easing_range_initial = 0
	M.xp[id].xp_max = M.get_level_max_xp(M.xp[id])
	M.xp[id].easing_range_total = math.min(M.xp[id].xp_current / M.xp[id].xp_max * 100, 100)
	M.xp[id].easing_range_total_new = M.xp[id].easing_range_total - M.xp[id].easing_range_initial
	M.xp[id].xp_current_visible = 0
	

	-- need check for needing to do another level up here?
end

function M.add_xp_to_id(id, amount)
	if M.xp[id].easing_range_initial ~= 100 then
		M.xp[id].easing_timer = 0
		M.xp[id].xp_current = M.xp[id].xp_current + amount
		M.xp[id].xp_accumulative = M.xp[id].xp_accumulative + amount
		M.xp[id].easing_range_initial = M.xp[id].easing_range_total
		M.xp[id].easing_range_total = math.min(M.xp[id].xp_current / M.xp[id].xp_max * 100, 100)
		M.xp[id].easing_range_total_new = M.xp[id].easing_range_total - M.xp[id].easing_range_initial
	end
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
function M.update_xp_current_text(node, xp_visible, xp_current, max_xp, ratio, dt)
	xp_visible = M.get_xp_current_text(xp_visible, xp_current, max_xp, ratio, dt)
	gui.set_text(node, xp_visible)
	return xp_visible
end

function M.get_xp_current_text(xp_visible, xp_current, max_xp, ratio, dt)
	dt = dt or 1
	assert(ratio > 0 and ratio <= 1, "XP: get_xp_current_text requires a ratio > 0 and <= 1")
	ratio = ratio or 0.14
	if math.abs(xp_visible - xp_current) <= 1 then
		xp_visible = xp_current
	else
		xp_visible = math.floor(xp_visible + (xp_current - xp_visible) * ratio * dt * 30)
	end
	return math.min(xp_visible, max_xp)
end

return M