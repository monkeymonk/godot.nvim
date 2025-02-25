--------------------------------------------------------------------------------
-- Godot Neovim Plugin
--
-- This plugin integrates Godot-specific debugging, LSP, and Treesitter into Neovim.
-- It provides a set of commands to control and manage a Godot debug session.
--------------------------------------------------------------------------------

local M = {}

-- =============================================================================
-- Module Imports
-- =============================================================================
local dap = require("godot.dap")
local debugger = require("godot.debugger")
local lsp = require("godot.lsp")
local treesitter = require("godot.treesitter")

-- =============================================================================
-- Default Configuration
-- =============================================================================
local default_config = {
	bin = "godot",
	dap = {
		host = "127.0.0.1",
		post = 6006,
	},
	expose_commands = true,
	gui = {
		console_config = {
			anchor = "SW",
			border = "double",
			col = 1,
			height = 10,
			relative = "editor",
			row = 99999,
			style = "minimal",
			width = 99999,
		},
	},
	pipepath = vim.fn.stdpath("cache") .. "/godot.pipe",
}

-- =============================================================================
-- Local Utility Functions
-- =============================================================================

--- Checks if a Neovim server is already running on the given pipe.
-- @param pipe string: The full path to the pipe.
-- @return boolean: Whether the pipe is found in the existing server list.
local function is_server_running(pipe)
	local servers = vim.fn.serverlist()
	for _, server in ipairs(servers) do
		if server == pipe then
			return true
		end
	end
	return false
end

-- =============================================================================
-- Plugin Setup
-- =============================================================================

--- Sets up the Godot plugin.
-- Merges user-provided configuration with defaults, ensures the Neovim server
-- is properly started for the given `pipepath`, and initializes submodules.
--
-- @param opts table|nil: A table containing user configuration overrides.
function M.setup(opts)
	-- Merge user config into the default config
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})

	-- Start server if not already running
	if not vim.loop.fs_stat(M.config.pipepath) and not is_server_running(M.config.pipepath) then
		vim.fn.serverstart(M.config.pipepath)
	end

	-- Initialize submodules with the final config
	dap.setup(M.config)
	debugger.setup(M.config)
	lsp.setup(M.config)
	treesitter.setup(M.config)
end

-- Automatically call setup on load (optional; some users prefer calling setup() in their config)
M.setup()

return M
