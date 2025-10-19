--------------------------------------------------------------------------------
-- Godot Debugger GUI
--
-- This module provides GUI elements for debugging: a console, a watcher window,
-- and associated logic for displaying trace, globals, members, and local scope.
--------------------------------------------------------------------------------

local M = {}

-- =============================================================================
-- Neovim API Shortcut
-- =============================================================================
local api = vim.api

-- =============================================================================
-- Local State
-- =============================================================================
local watcher_buffer = nil
local watcher_window = nil
local console_buffer = nil
local console_window = nil
local code_window = nil

local watcher_locals = {}
local watcher_globals = {}
local watcher_members = {}
local watcher_trace = {}

local console_line_counter = 0
local config = {}

-- =============================================================================
-- Setup
-- =============================================================================

--- Initializes the GUI debugger module.
-- @param opts table: Configuration table to override defaults.
function M.setup(opts)
	config = opts or {}
	code_window = api.nvim_get_current_win()
end

-- =============================================================================
-- Console Window Methods
-- =============================================================================

--- Opens the console window using the provided configuration.
function M.open_console()
	console_buffer = api.nvim_create_buf(false, true)
	console_window = api.nvim_open_win(console_buffer, false, config.gui.console_config)
	-- Return to the code window
	api.nvim_set_current_win(code_window)
end

--- Closes the console window if it exists.
function M.close_console()
	if console_buffer then
		api.nvim_buf_delete(console_buffer, { force = true })
		console_buffer = nil
		console_window = nil
		console_line_counter = 0
	end
end

-- =============================================================================
-- Watcher Window Methods
-- =============================================================================

--- Opens the watcher window in a vertical split to display debug info.
function M.open_watcher()
	api.nvim_set_current_win(code_window)
	vim.cmd("vsplit")

	watcher_buffer = api.nvim_create_buf(false, true)
	watcher_window = api.nvim_get_current_win()
	api.nvim_win_set_buf(watcher_window, watcher_buffer)
end

--- Closes the watcher window if it exists.
function M.close_watcher()
	if watcher_buffer then
		api.nvim_buf_delete(watcher_buffer, { force = true })
		watcher_buffer = nil
		watcher_window = nil
	end
end

-- =============================================================================
-- Debug Information Setters
-- =============================================================================

--- Sets the current trace and attempts to jump to the first frame if found.
-- @param trace table: A list of lines describing the stack trace.
function M.set_trace(trace)
	watcher_trace = trace

	for _, line in pairs(trace) do
		if string.find(line, "*Frame.+res://") then
			M.jump_cursor(line)
		end
	end
end

--- Sets the list of global variables.
-- @param globals table: A list of strings representing global vars.
function M.set_globals(globals)
	watcher_globals = globals
end

--- Sets the list of class members.
-- @param members table: A list of strings representing class members.
function M.set_members(members)
	watcher_members = members
end

--- Sets the list of local variables.
-- @param locals table: A list of strings representing local vars.
function M.set_locals(locals)
	watcher_locals = locals
end

-- =============================================================================
-- Cursor Jump
-- =============================================================================

--- Jumps the Neovim cursor to the file/line indicated in the stack trace string.
-- @param trace_line string: The full debug trace line.
function M.jump_cursor(trace_line)
	local file_line = string.match(trace_line, "res://.+:%d+")
	if not file_line then
		return
	end

	file_line = string.gsub(file_line, "res://", "")
	local file, line = unpack(vim.split(file_line, ":"))

	api.nvim_set_current_win(code_window)
	vim.cmd("e +" .. line .. " " .. file)
	vim.cmd("normal! zz")
end

-- =============================================================================
-- Console Logging
-- =============================================================================

--- Appends a line to the console buffer if it exists.
-- @param line string: The line to append to the console buffer.
function M.console_log(line)
	if console_buffer and api.nvim_buf_is_valid(console_buffer) and #line > 0 then
		api.nvim_buf_set_lines(console_buffer, console_line_counter, console_line_counter + 1, false, { line })
		api.nvim_win_set_cursor(console_window, { console_line_counter + 1, 0 })
		console_line_counter = console_line_counter + 1
	end
end

-- =============================================================================
-- Watcher Rendering
-- =============================================================================

--- Renders the full watcher state (globals, members, locals, trace) to the
-- watcher buffer.
function M.print_watcher()
	local text = {}

	table.insert(text, "_________________________________________")
	table.insert(text, "-- Godot Debugger 1.0")

	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- global --")
	if watcher_globals then
		for _, line in pairs(watcher_globals) do
			table.insert(text, "#" .. line)
		end
	end

	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- class --")
	if watcher_members then
		for _, line in pairs(watcher_members) do
			table.insert(text, "#" .. line)
		end
	end

	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- scope --")
	if watcher_locals then
		for _, line in pairs(watcher_locals) do
			table.insert(text, "#" .. line)
		end
	end

	table.insert(text, "")
	table.insert(text, "________________________________________")
	table.insert(text, "-- stack")
	if watcher_trace then
		for _, line in pairs(watcher_trace) do
			table.insert(text, line)
		end
	end

	api.nvim_buf_set_lines(watcher_buffer, 0, -1, true, text)
end

return M
