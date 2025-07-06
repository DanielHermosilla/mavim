local Job = require("manim_plugin.job")
local M = {}

local defaults = {
	manim_executable = "manim",
	build_dir = "media/videos",
	default_quality = "-pqh",
	live_preview = false,
}

-- Comprueba si un string parece un flag de calidad (-p...)
local function is_quality_flag(s)
	return s:match("^%-p") ~= nil
end

function M.define(user_opts)
	local o = vim.tbl_extend("force", defaults, user_opts or {})

	vim.api.nvim_create_user_command("ManimRender", function(ctx)
		-- 1) fichero actual
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			vim.notify("No buffer file detected", vim.log.levels.ERROR)
			return
		end

		-- 2) parseo de argumentos: opcional quality + lista de escenas
		local fargs = ctx.fargs
		local quality, scenes

		if is_quality_flag(fargs[1]) then
			quality = fargs[1]
			scenes = vim.list_slice(fargs, 2)
		else
			quality = o.default_quality
			scenes = vim.deepcopy(fargs)
		end

		if #scenes == 0 then
			vim.notify("Usage: ManimRender [quality] [Scene1] [Scene2] ...", vim.log.levels.ERROR)
			return
		end

		-- 3) lanzar el job con lista de escenas
		Job.render(o, file, scenes, quality)
	end, {
		nargs = "+",
		complete = function()
			return {}
		end,
	})
end

return M
