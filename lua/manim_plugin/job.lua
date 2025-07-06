local M = {}

--- Renderize manim scenes using a background job.
-- @param opts table with options, such as the executable path, build directory, and default quality.
-- @param file route to the .py
-- @param scenes table with the scene names
-- @param quality quality flags ("-pqh", "-pql", …)
-- @param on_done
function M.render(opts, file, scenes, quality, on_done)
	quality = quality or opts.default_quality

	-- Construct the manim executable command
	local args = {
		opts.manim_executable,
		quality,
		"--media_dir",
		opts.build_dir,
		file,
	}
	vim.list_extend(args, scenes)

	-- Get the outputs
	local stderr = {}

	-- Launch the background job
	local job_id = vim.fn.jobstart(args, {
		cwd = vim.fn.getcwd(),
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data, _)
			-- Capture stdout, until now it is not necessary
		end,
		on_stderr = function(_, data, _)
			if data then
				for _, line in ipairs(data) do
					table.insert(stderr, line)
				end
			end
		end,
		on_exit = vim.schedule_wrap(function(_, exit_code, _)
			if exit_code == 0 then
				vim.notify("✅ Manim was compiled.", vim.log.levels.INFO)
				if on_done then
					-- calcula rutas de salida para cada escena
					local outputs = {}
					local base = vim.fn.fnamemodify(file, ":r")
					for _, scene in ipairs(scenes) do
						table.insert(outputs, string.format("%s/%s/%s.mp4", opts.build_dir, base, scene))
					end
					on_done(outputs)
				end
			else
				vim.notify(
					"❌ Error in Manim:\n" .. table.concat(stderr, "\n"),
					vim.log.levels.ERROR,
					{ title = "ManimRender" }
				)
			end
		end),
	})

	if job_id <= 0 then
		vim.notify("Manim couldn't be initialized (" .. tostring(job_id) .. ")", vim.log.levels.ERROR)
	end
end

return M
