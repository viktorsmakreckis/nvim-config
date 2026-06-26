local dap = require "dap"
local dapui = require "dapui"

-- UI + inline variable values ----------------------------------------------
dapui.setup()
require("nvim-dap-virtual-text").setup {}

-- Nicer signs in the gutter
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DiagnosticHint", numhl = "" })

-- Open/close the UI automatically with the session
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

-- netcoredbg adapter (platform aware) --------------------------------------
local uname = vim.uv.os_uname()
local is_mac_arm = uname.sysname == "Darwin" and uname.machine == "arm64"

if is_mac_arm then
  -- No upstream arm64 build of netcoredbg exists, so this plugin ships its
  -- own. setup() registers the `coreclr` and `netcoredbg` adapters AND a
  -- `dap.configurations.cs` launch config with a smart DLL picker + .env load.
  require("netcoredbg-macOS-arm64").setup()
else
  local netcoredbg = vim.fn.exepath "netcoredbg"
  if netcoredbg == "" then
    netcoredbg = vim.fn.stdpath "data" .. "/mason/bin/netcoredbg"
  end
  dap.adapters.netcoredbg = {
    type = "executable",
    command = netcoredbg,
    args = { "--interpreter=vscode" },
  }
  dap.adapters.coreclr = dap.adapters.netcoredbg
end

-- C# launch config (only define if the arm64 plugin didn't already) --------
if not dap.configurations.cs then
  local function pick_dll()
    return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
  end

  dap.configurations.cs = {
    {
      type = "netcoredbg",
      name = "NetCoreDbg: Launch",
      request = "launch",
      cwd = "${fileDirname}",
      program = pick_dll,
    },
    {
      type = "netcoredbg",
      name = "NetCoreDbg: Attach to process",
      request = "attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

-- Reuse the C# configs for F# / VB if you ever touch them
dap.configurations.fsharp = dap.configurations.cs
