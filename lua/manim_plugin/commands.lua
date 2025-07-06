-- commands.lua
local Job = require("manim_plugin.job")
local M = {}

local defaults = {
	manim_executable = "manim",
	manim_slides_executable = "manim-slides",
	build_dir = "media/videos",
	default_quality = "-pqh",
	live_preview = false,
}

local function is_quality_flag(arg)
	return arg:match("^%-p") ~= nil
end

function M.define(user_opts)
	local opts = vim.tbl_extend("force", defaults, user_opts or {})

	-- :ManimRender [quality] <Scene...>
	vim.api.nvim_create_user_command("ManimRender", function(ctx)
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			vim.notify("No file detected in current buffer", vim.log.levels.ERROR)
			return
		end
		local args = ctx.fargs
		local quality, scenes
		if is_quality_flag(args[1]) then
			quality = args[1]
			scenes = vim.list_slice(args, 2)
		else
			quality = opts.default_quality
			scenes = vim.deepcopy(args)
		end
		if #scenes == 0 then
			vim.notify("Usage: ManimRender [quality] <Scene1> [Scene2 ...]", vim.log.levels.ERROR)
			return
		end
		Job.render(opts, file, scenes, quality)
	end, {
		nargs = "+",
		complete = function()
			return {}
		end,
	})

	-- :ManimSlideRender <Slide...>
	vim.api.nvim_create_user_command("ManimSlideRender", function(ctx)
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			vim.notify("Ensure you are editing a .py file", vim.log.levels.ERROR)
			return
		end
		local slides = vim.deepcopy(ctx.fargs)
		if #slides == 0 then
			vim.notify("Usage: ManimSlideRender <Slide1> [Slide2 ...]", vim.log.levels.ERROR)
			return
		end
		Job.render_slides(opts, file, slides)
	end, {
		nargs = "+",
		complete = function()
			return {}
		end,
	})

	-- :ManimSlidesPresent <Slide...>
	vim.api.nvim_create_user_command("ManimSlidesPresent", function(ctx)
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			vim.notify("Ensure you are editing a .py file", vim.log.levels.ERROR)
			return
		end
		local slides = vim.deepcopy(ctx.fargs)
		if #slides == 0 then
			vim.notify("Usage: ManimSlidesPresent <Slide1> [Slide2 ...]", vim.log.levels.ERROR)
			return
		end
		Job.present_slides(opts, file, slides)
	end, {
		nargs = "+",
		complete = function()
			return {}
		end,
	})
end

return M
