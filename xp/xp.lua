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

return M