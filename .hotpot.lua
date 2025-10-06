return {
	build = {
		{ verbose = true },
		-- This will only compile init.fnl, all other fnl/ files will behave as normal.
		{ "init.fnl", true },
		-- Or you could enable other patterns too,
		-- {"colors/*.fnl", true},
		{ "fnl/**/*.fnl", true },
	},
}
