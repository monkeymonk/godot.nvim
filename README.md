# lommix/godot.nvim

> A Neovim plugin that seamlessly integrates [Godot](https://godotengine.org/) for GDScript development, debugging, and more — all without leaving Neovim’s powerful editing environment.

![nvimgodotlogo](https://user-images.githubusercontent.com/84206502/192011201-988b79c3-e688-4c6d-b00b-720aadff35dc.png)


## Demo

[godotnvim.webm](https://user-images.githubusercontent.com/84206502/191308246-8d6d963f-1934-4339-ae87-dbec4d62e2f4.webm)


## Features

- Debugging:
  - Attach to Godot to debug your scene.
  - Break on cursor or on runtime errors.
  - Step, continue, quit — all from within Neovim.

- Godot 3 & 4 Support:
  - Works with older Godot 3 projects or the latest Godot 4 DAP integration.

- Language Server (LSP):
  - Includes a simple setup for GDScript LSP (via `lspconfig`).

- Treesitter Integration:
  - Basic grammar highlighting for `gdscript`, `godot_resource`, and `gdshader` files.

- Watchers and Console:
  - On break, open a watcher window that shows local variables, globals, members, and a trace.
  - A separate console window logs information from the running Godot process.


## Requirements

- [Neovim 0.7+](https://neovim.io/) (for Lua-based config)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap) for debugging (optional, but strongly recommended)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for syntax highlighting (optional but recommended)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for GDScript LSP (optional but recommended)
- A local Godot executable (`godot` or `godot4`, etc.)


## Installation

Use your favorite plugin manager. For example, with  [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "lommix/godot.nvim",
  lazy = true,
  cmd = { "GodotDebug", "GodotBreakAtCursor", "GodotStep", "GodotQuit", "GodotContinue" },
},
```


## Configuration

In your Neovim configuration, create a file or directly place:

```lua
{
  -- Path to your Godot executable
  bin = "godot",

  -- DAP configuration
  dap = {
    host = "127.0.0.1",
    port = 6006,
  },

  -- GUI settings for console (passed to nvim_open_win)
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

  -- Expose user commands automatically (optional)
  expose_commands = true,
}
```


## Usage

Commands (if `expose_commands = true` or if you call `godot.debugger.expose_commands()` manually):

- `:GodotDebug` – Launch Godot in debug mode.
- `:GodotBreakAtCursor` – Launch Godot and break at the current cursor line in a `.gd` file.
- `:GodotStep` – Step to the next instruction.
- `:GodotContinue` – Continue execution after a break.
- `:GodotQuit` – Quit the current debug session.

In addition, the plugin creates two special windows on break:

- A console window showing log output.
- A watcher window displaying current locals, globals, and trace data.


## Contributing

Feel free to open [issues](https://github.com/lommix/godot.nvim/issues) or submit pull requests to enhance this plugin.

## License

[MIT](https://github.com/Lommix/godot.nvim/blob/main/LICENSE) © 2023 Contributors

