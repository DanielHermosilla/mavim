-- lua/manim_plugin/job.lua
local M = {}

--- Render one or more Manim scenes using a background job.
-- @param opts    Table of configuration options (manim_executable, build_dir, default_quality)
-- @param file    Path to the current .py source file
-- @param scenes  Array of scene class names to render
-- @param quality Render quality flag (e.g. "-pqh", "-pql"); defaults to opts.default_quality
-- @param on_done Optional callback invoked with the list of output file paths upon success
function M.render(opts, file, scenes, quality, on_done)
	quality = quality or opts.default_quality

	-- Build the Manim command arguments
	local args = {
		opts.manim_executable,
		quality,
		"--media_dir",
		opts.build_dir,
		file,
	}
	vim.list_extend(args, scenes)

	-- Buffers to collect stdout and stderr
	local stdout, stderr = {}, {}

	-- Notify start
	vim.notify(
		"▶️ Starting Manim render: " .. table.concat(scenes, ", "),
		vim.log.levels.INFO,
		{ title = "ManimRender" }
	)

	-- Launch the job in background
	local job_id = vim.fn.jobstart(args, {
		cwd = vim.fn.getcwd(),
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr, data)
			end
		end,
		on_exit = vim.schedule_wrap(function(_, exit_code)
			-- Detect Python traceback in stdout
			local has_traceback = false
			for _, line in ipairs(stdout) do
				if line:match("Traceback") then
					has_traceback = true
					break
				end
			end
			local failed = exit_code ~= 0 or has_traceback

			if not failed then
				vim.notify("✅ Manim render completed successfully.", vim.log.levels.INFO, { title = "ManimRender" })
				if on_done then
					local outputs = {}
					local base = vim.fn.fnamemodify(file, ":r")
					for _, scene in ipairs(scenes) do
						table.insert(outputs, string.format("%s/%s/%s.mp4", opts.build_dir, base, scene))
					end
					on_done(outputs)
				end
			else
				-- Combine stdout and stderr for error report
				local log = vim.deepcopy(stdout)
				vim.list_extend(log, stderr)
				vim.notify(
					"❌ Manim render failed:\n" .. table.concat(log, "\n"),
					vim.log.levels.ERROR,
					{ title = "ManimRender" }
				)
			end
		end),
	})

	if job_id <= 0 then
		vim.notify(
			"❌ Failed to start Manim (jobstart returned " .. tostring(job_id) .. ")",
			vim.log.levels.ERROR,
			{ title = "ManimRender" }
		)
	end
end

--- Render slides using the `manim-slides render` CLI in the background.
-- @param opts   Table of configuration options (manim_slides_executable)
-- @param file   Path to the current .py source file
-- @param slides Array of slide class names to render
function M.render_slides(opts, file, slides)
	-- Build the manim-slides render command
	local cmd = {
		opts.manim_slides_executable or "manim-slides",
		"render",
		file,
	}
	vim.list_extend(cmd, slides)

	-- Buffers to collect stdout and stderr
	local stdout, stderr = {}, {}

	-- Notify start
	vim.notify(
		"▶️ Starting slide render: " .. table.concat(slides, ", "),
		vim.log.levels.INFO,
		{ title = "ManimSlidesRender" }
	)

	-- Launch the job in background
	local job_id = vim.fn.jobstart(cmd, {
		cwd = vim.fn.getcwd(),
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr, data)
			end
		end,
		on_exit = vim.schedule_wrap(function(_, exit_code)
			-- Detect Python traceback in stdout
			local has_traceback = false
			for _, line in ipairs(stdout) do
				if line:match("Traceback") then
					has_traceback = true
					break
				end
			end
			local failed = exit_code ~= 0 or has_traceback

			if not failed then
				vim.notify(
					"✅ Slide render completed successfully.",
					vim.log.levels.INFO,
					{ title = "ManimSlidesRender" }
				)
			else
				-- Combine stdout and stderr for error report
				local log = vim.deepcopy(stdout)
				vim.list_extend(log, stderr)
				vim.notify(
					"❌ Slide render failed:\n" .. table.concat(log, "\n"),
					vim.log.levels.ERROR,
					{ title = "ManimSlideRender" }
				)
			end
		end),
	})

	if job_id <= 0 then
		vim.notify(
			"❌ Failed to start slide render (jobstart returned " .. tostring(job_id) .. ")",
			vim.log.levels.ERROR,
			{ title = "ManimSlideRender" }
		)
	end
end

--- Present slides using the `manim-slides present` CLI in the background.
-- @param opts   Table of configuration options (manim_slides_executable)
-- @param file   Path to the current .py source file
-- @param slides Array of slide class names to present
function M.present_slides(opts, file, slides)
	-- Build the manim-slides present command
	local cmd = {
		opts.manim_slides_executable or "manim-slides",
		"present",
		-- file,
	}
	vim.list_extend(cmd, slides)

	-- Buffers to collect stdout and stderr
	local stdout, stderr = {}, {}

	-- Notify start
	vim.notify(
		"▶️ Starting slide presentation: " .. table.concat(slides, ", "),
		vim.log.levels.INFO,
		{ title = "ManimSlidesPresent" }
	)

	-- Launch the job in background
	local job_id = vim.fn.jobstart(cmd, {
		cwd = vim.fn.getcwd(),
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr, data)
			end
		end,
		on_exit = vim.schedule_wrap(function(_, exit_code)
			-- Detect Python traceback in stdout
			local has_traceback = false
			for _, line in ipairs(stdout) do
				if line:match("Traceback") then
					has_traceback = true
					break
				end
			end
			local failed = exit_code ~= 0 or has_traceback

			if not failed then
				vim.notify(
					"✅ Slide presentation completed successfully.",
					vim.log.levels.INFO,
					{ title = "ManimSlidesPresent" }
				)
			else
				-- Combine stdout and stderr for error report
				local log = vim.deepcopy(stdout)
				vim.list_extend(log, stderr)
				vim.notify(
					"❌ Slide presentation failed:\n" .. table.concat(log, "\n"),
					vim.log.levels.ERROR,
					{ title = "ManimSlidesPresent" }
				)
			end
		end),
	})

	if job_id <= 0 then
		vim.notify(
			"❌ Failed to start slide presentation (jobstart returned " .. tostring(job_id) .. ")",
			vim.log.levels.ERROR,
			{ title = "ManimSlidesPresent" }
		)
	end
end

return M
