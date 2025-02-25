--------------------------------------------------------------------------------
-- Godot Debugger Module
--
-- Provides debugging functionality via Godot's job API, including breakpoints,
-- stepping, and watchers. This module integrates a GUI component for outputs.
--------------------------------------------------------------------------------

local M = {}

-- =============================================================================
-- Dependencies
-- =============================================================================
local gui = require("godot.debugger.gui")
local godot_job = require("godot.debugger.job")

-- =============================================================================
-- Local State and Configuration
-- =============================================================================
local config = {}
local current_job = nil
local debug_mode = false

-- Default configuration that can be overridden by user options
local default_config = {
	-- Example for your usage:
	bin = "godot", -- Path to the Godot binary
	expose_commands = false,
}

-- =============================================================================
-- Local Utility Functions
-- =============================================================================

--- Log lines to the GUI console.
-- @param line string: A line of text to be logged in the debugger console.
local function on_log(line)
	gui.console_log(line)
end

--- Reloads various watchers (globals, members, locals, backtrace).
local function reload_watcher()
	godot_job:request("gv", function(response)
		gui.set_globals(response)
	end)

	godot_job:request("mv", function(response)
		gui.set_members(response)
	end)

	godot_job:request("lv", function(response)
		gui.set_locals(response)
	end)

	godot_job:request("bt", function(response)
		gui.set_trace(response)
		gui.print_watcher()
	end)
end

--- Enters debug mode in the GUI, opening watchers and reloading debug data.
local function on_enter_debug()
	gui.open_watcher()
	reload_watcher()
end

--- Starts the Godot debugging job.
-- @param command table: The command line used to start Godot in debug mode.
-- @param cwd string: The working directory.
local function start_job(command, cwd)
	debug_mode = false
	current_job = godot_job:new({
		cmd = command,
		cwd = cwd,
		on_log = on_log,
		on_break = function()
			if not debug_mode then
				on_enter_debug()
			end
			debug_mode = true
		end,
		on_exit = function()
			gui.close_console()
			gui.close_watcher()
		end,
	})
end

-- =============================================================================
-- Public Methods
-- =============================================================================

--- Sets up the debugger configuration and GUI, optionally exposing commands.
-- @param opts table|nil: User overrides for configuration.
function M.setup(opts)
	config = vim.tbl_deep_extend("force", default_config, opts or {})
	gui.setup(config)

	if config.expose_commands then
		M.expose_commands()
	end
end

--- Debug at the current cursor position in a GDScript file.
function M.debug_at_cursor()
	local line = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
	local file = vim.fn.expand("%")

	if not string.find(file, "%.gd$") then
		print("This action requires a GDScript (.gd) file.")
		return
	end

	if current_job then
		current_job:shutdown()
	end

	local command = { config.bin, "-d", "-b", "res://" .. file .. ":" .. line }
	local cwd = vim.fn.getcwd()

	gui.open_console()
	start_job(command, cwd)
end

--- Quit the current debug session.
function M.quit()
	if current_job then
		current_job:shutdown()
	end
end

--- Step through the code in debug mode.
function M.step()
	current_job:request("s", function(response)
		for _, line in pairs(response) do
			-- If there's a new debugger break, stop processing further lines
			if line:find("Debugger Break,") then
				break
			end
			gui.console_log(line)
		end
		reload_watcher()
	end)
end

--- Continue running code in debug mode (after a break).
function M.continue()
	-- Close the watcher so we can reopen if we break again
	gui.close_watcher()
	current_job:request("c", function()
		on_enter_debug()
	end)
end

--- Start a new Godot debug session without a break-at-cursor.
function M.debug()
	if current_job then
		current_job:shutdown()
	end

	local command = { config.bin, "-d" }
	local cwd = vim.fn.getcwd()

	gui.open_console()
	start_job(command, cwd)
end

--- Optionally exposes user commands for convenience in the Neovim command line.
function M.expose_commands()
	vim.api.nvim_create_user_command("GodotDebug", M.debug, {})
	vim.api.nvim_create_user_command("GodotBreakAtCursor", M.debug_at_cursor, {})
	vim.api.nvim_create_user_command("GodotStep", M.step, {})
	vim.api.nvim_create_user_command("GodotQuit", M.quit, {})
	vim.api.nvim_create_user_command("GodotContinue", M.continue, {})
end

return M
