--------------------------------------------------------------------------------
-- Godot LSP Setup
--
-- This module sets up the GDScript language server through lspconfig.
-- Note: The Godot editor must be open (or the project must be open in Godot)
-- for the GDScript LSP to function correctly.
--------------------------------------------------------------------------------

local M = {}

--- Sets up the GDScript LSP using lspconfig, optionally merging user config.
-- @param opts table|nil A table of user overrides.
function M.setup(opts)
	local ok, lspconfig = pcall(require, "lspconfig")
	if not ok then
		-- Bail out if lspconfig is not available
		return
	end

	-- Define defaults or merge additional config if desired
	local default_config = {
		lsp_opts = {},
	}

	local config = vim.tbl_deep_extend("force", default_config, opts or {})

	-- Setup GDScript LSP with merged configuration
	lspconfig.gdscript.setup(config.lsp_opts)
end

return M
