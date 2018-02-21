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
	
return M