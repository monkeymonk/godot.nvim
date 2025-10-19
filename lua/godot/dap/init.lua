--------------------------------------------------------------------------------
-- Godot DAP Setup
--
-- Configures the Neovim DAP (nvim-dap) adapter for Godot.
-- References:
--   - https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html#lsp-dap-support
--   - https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#godot-gdscript
--------------------------------------------------------------------------------

local M = {}

--- Sets up the DAP configuration for Godot (GDScript).
-- @param opts table|nil An optional table containing config overrides.
function M.setup(opts)
	local ok, dap = pcall(require, "dap")
	if not ok then
		return
	end

	-- Default configuration
	local default_config = {
		dap = {
			host = "127.0.0.1",
			port = 6006, -- Default debug port
		},
	}

	-- Merge user opts into default config
	local config = vim.tbl_deep_extend("force", default_config, opts or {})

	-- Define the Godot adapter
	-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#godot-gdscript
	dap.adapters.godot = {
		type = "server",
		host = config.dap.host,
		port = config.dap.port,
	}

	-- Define the launch configuration for GDScript
	dap.configurations.gdscript = {
		{
			type = "godot",
			request = "launch",
			name = "Launch scene",
			launch_scene = true,
			project = "${workspaceFolder}",
		},
	}
end

return M
