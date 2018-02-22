return {

	--[[
	style:
	1 - look up table list
	2 - formula
	
	--]]
	shooter = {
		level = 0,
		xp_needed = 0,
		total_xp = 0,
		style = 1, -- style determines the behavior of leveling up - using look up table vs formulas
		loop = false, -- to loop back to level 1 or not once loop_level is reached
		loop_level = 100,
		loop_reset_xp_amounts = false,
		loops_done = 0, -- loops done, can show stars next to level showing loops
		max_level = 100,
		limit_by_max_level = false,
		
		formula = {
			1 = "level * 200", -- you can define different formulas for different level ranges
			10 = "level * 250 + level * level * 100",
			50 = "level * level * level",
		},
		xp_amounts = { -- this is a lookup table so you can easily control level amounts
			2000, -- 1
			3500, --  2
			5000,  -- 3
			6500,  -- 4
			7500,  -- 5
			8500,  -- 6
			9500,  -- 7
			10500,  -- 8
			11500,  -- 9
			12500, -- 10
			13500,  -- 11
			14500,  -- 12
			15000,  -- 13
			16000,  -- 14
			16500,  -- 15
			17000,  -- 16
			17500,  -- 17
			18000,  -- 18
			18500, -- 19
			19000,  -- 20
			20000 -- 21+
		},

		

	},
	arpg = {},
	rpg = {},	

}
