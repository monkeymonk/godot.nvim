--------------------------------------------------------------------------------
-- Godot Treesitter Setup
--
-- This module sets up nvim-treesitter for Godot-specific languages:
--   - GDScript
--   - Godot Resource
--   - GDShader
--
-- References:
--   https://github.com/nvim-treesitter/nvim-treesitter/blob/4d7580099155065f196a12d7fab412e9eb1526df/lua/nvim-treesitter/configs.lua#L371-L372
--------------------------------------------------------------------------------

local M = {}

--- Sets up Treesitter for Godot languages, optionally merging user config.
-- @param opts table|nil A table of user overrides for nvim-treesitter.
function M.setup(opts)
	local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
	if not ok then
		-- If nvim-treesitter is not available, bail out
		return
	end

	-- Default configuration
	local default_config = {
		ensure_installed = { "gdscript", "godot_resource", "gdshader" },
	}

	-- Merge user overrides with defaults
	local final_config = vim.tbl_deep_extend("force", default_config, opts or {})

	ts_configs.setup(final_config)
end

return M
