local M = {}

-- Carga internals
local commands = require("manim_plugin.commands")

function M.setup(opts)
	opts = opts or {}
	commands.define(opts)
end

return M
