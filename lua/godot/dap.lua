local ok, dap = pcall(require, "dap")
if not ok then
	return
end

local config = require("godot.init").config

-- @see https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html#lsp-dap-support
-- @see https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#godot-gdscript

dap.adapters.godot = {
	-- debugServer = 6006,
	host = config.dap.host,
	port = config.dap.port,
	type = "server",
}

dap.configurations.gdscript = {
	{
		launch_scene = true,
		name = "Launch scene",
		project = "${workspaceFolder}",
		request = "launch",
		type = "godot",
	},
}
