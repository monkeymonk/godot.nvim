--------------------------------------------------------------------------------
-- Job Module
-- Manages a Godot debugger job process, handling command queueing, output, etc.
--------------------------------------------------------------------------------

local fn = vim.fn

local Job = {}

--------------------------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------------------------

--- Handles lines from stdout, dispatching them to callbacks or the active command.
-- @param job Job: The current Job instance.
-- @param lines table: A list of lines received from stdout.
local function on_stdout(job, lines)
	for _, line in ipairs(lines) do
		-- Check if debug prompt is encountered
		if line:find("debug>") then
			-- If there is an active command, call its response callback, then process queue
			if job.current_cmd then
				if job.response_callback then
					job.response_callback(job.response_buffer)
				end
				job.current_cmd = nil
				job:process_queue()
			end
			-- Notify that we have hit a debugger break
			job.on_break()
		-- Move to the next line
		elseif #vim.trim(line) == 0 then
		-- Skip empty lines
		elseif job.current_cmd and job.current_cmd ~= "c" then
			-- If we have an active command (not 'continue'), accumulate output
			table.insert(job.response_buffer, line)
		elseif line == 'Enter "help" for assistance.' then
		-- Skip this line
		else
			-- Log everything else
			job.on_log(line)
		end
	end
end

--------------------------------------------------------------------------------
-- Job Methods
--------------------------------------------------------------------------------

--- Processes the next queued debugger command, if any.
function Job:process_queue()
	if #self.queue > 0 then
		local next_cmd = table.remove(self.queue, 1)
		self.current_cmd = next_cmd[1]
		self.response_callback = next_cmd[2]
		self.response_buffer = {}

		fn.chansend(self.job_id, self.current_cmd .. "\n")
	end
end

--- Sends a debugger command (request) to the Godot debugger.
-- If there is an existing active command, the new one is queued.
-- @param debugger_request string: The command to send (e.g., "s", "c").
-- @param callback function|nil: A function to receive the command's output.
function Job:request(debugger_request, callback)
	if not self.current_cmd then
		self.current_cmd = debugger_request
		self.response_buffer = {}
		self.response_callback = callback
		fn.chansend(self.job_id, debugger_request .. "\n")
	else
		table.insert(self.queue, { debugger_request, callback })
	end
end

--- Stops the underlying job process.
function Job:shutdown()
	fn.jobstop(self.job_id)
end

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

--- Creates a new Job instance.
-- @param o table: Table containing fields:
--   - cmd string|table: The executable and arguments (passed to jobstart).
--   - cwd string: The working directory for the job.
--   - on_log function: Callback to log output lines not tied to a command.
--   - on_break function: Callback when the debugger hits a break.
--   - on_exit function: Callback when the job exits.
-- @return table: A new Job instance.
function Job:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	-- Basic assertion checks
	assert(o.cmd, "missing executable")
	assert(o.on_log, "missing log callback")
	assert(o.on_break, "missing break callback")
	assert(o.cwd, "missing project directory")

	-- Create the underlying job
	o.job_id = fn.jobstart(o.cmd, {
		cwd = o.cwd,
		on_stdout = function(_, data)
			on_stdout(o, data)
		end,
		on_exit = o.on_exit,
	})

	-- Initialize command queue and active command info
	o.queue = {}
	o.current_cmd = nil
	o.response_buffer = nil
	o.response_callback = nil

	return o
end

return Job
