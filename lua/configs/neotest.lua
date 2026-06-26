-- neotest-vstest config must be set BEFORE the adapter is required.
-- It uses VSTest / Microsoft.Testing.Platform, so it supports xUnit, NUnit,
-- MSTest, TUnit, C# and F# with no extra dependencies beyond the dotnet SDK.
vim.g.neotest_vstest = {
  -- Passed straight to nvim-dap when you debug a test (matches dap.lua adapter)
  dap_settings = {
    type = "netcoredbg",
  },
  -- If no obvious parent solution is found, scan downward for .sln files.
  broad_recursive_discovery = false,
}

require("neotest").setup {
  adapters = {
    require "neotest-vstest",
  },
  -- show inline pass/fail virtual text and a sign in the gutter
  status = { virtual_text = true },
  output = { open_on_run = false },
  quickfix = { enabled = false },
}
