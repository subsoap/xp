local M = {}

M.xp_data_filename = "/xp/blank_data.lua"
M.xp_data = {}
M.initiated = false
M.verbose = false

function M.init()
	M.xp_data = assert(loadstring(sys.load_resource(M.xp_data_filename)))()
	M.initiated = true
	if M.verbose == true then print("XP: Initialized") end
end

function M.get_data()
end

function M.load_data()
end

function M.create_id(id)
end

function M.add_xp(id, amount)
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
function M.update_current_xp_text(node, xp_visible, current_xp, max_xp)
	if math.abs(xp_visible - current_xp) <= 1 then
		xp_visible = current_xp
	else
		xp_visible = math.floor(xp_visible + (current_xp - xp_visible) * 0.14)
	end
	gui.set_text(node, math.min(xp_visible, max_xp))
	return xp_visible
end
	
return M