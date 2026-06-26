return {
  -- Formatting (config in lua/configs/conform.lua)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- LSP (config in lua/configs/lspconfig.lua)
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Replace nvim-cmp with blink.cmp (NvChad's official integration).
  -- This disables nvim-cmp and rewires autopairs/snippets automatically.
  { import = "nvchad.blink.lazyspec" },

  -- Mason: add the Crashdummyy registry so the Razor-capable `roslyn`
  -- package is available (required for Blazor / .razor / .cshtml).
  {
    "mason-org/mason.nvim",
    opts = function()
      local opts = require "nvchad.configs.mason"
      opts.registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      }
      return opts
    end,
  },

  -- Auto-install every LSP server / formatter we use.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = function()
      local ensure = {
        -- LSP servers
        "lua-language-server",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "vtsls", -- TypeScript / JavaScript / React / Next.js
        "eslint-lsp", -- JS/TS linting + fix on save
        "tailwindcss-language-server", -- Tailwind CSS
        "emmet-language-server", -- Emmet for html/jsx/svelte/razor
        "angular-language-server", -- Angular
        "svelte-language-server", -- Svelte / SvelteKit
        "pyright", -- Python types (FastAPI)
        "ruff", -- Python lint + format (LSP)
        "roslyn", -- C# / .NET / Blazor (Razor via cohosting)

        -- Formatters
        "stylua", -- Lua
        "prettierd", -- JS/TS/CSS/HTML/JSON/MD/Svelte
        "prettier", -- prettierd fallback
        "csharpier", -- C#
      }
      -- netcoredbg has no upstream arm64 build, so on Apple Silicon it is
      -- provided by the netcoredbg-macOS-arm64.nvim plugin instead of mason.
      local uname = vim.uv.os_uname()
      if not (uname.sysname == "Darwin" and uname.machine == "arm64") then
        table.insert(ensure, "netcoredbg")
      end
      return { run_on_start = true, ensure_installed = ensure }
    end,
  },

  -- C# / .NET / Blazor language server. rzls.nvim is deprecated: Razor is
  -- now handled by roslyn itself via cohosting (needs the `roslyn` mason
  -- package above, which bundles the Razor extensions, and .NET SDK 10+).
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    init = function()
      vim.filetype.add {
        extension = { razor = "razor", cshtml = "razor" },
      }
    end,
    config = function()
      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
          },
        },
      })
      require("roslyn").setup {
        broad_search = true, -- find .sln files in sibling directories too
      }
    end,
  },

  -- Treesitter parsers for the whole stack
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local opts = require "nvchad.configs.treesitter"
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c_sharp",
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "jsonc",
        "python",
        "svelte",
        "angular",
        "markdown",
        "markdown_inline",
        "yaml",
        "toml",
        "bash",
        "dockerfile",
        "gitignore",
        "regex",
      })
      return opts
    end,
  },

  -- Debugging: nvim-dap + UI + netcoredbg (.NET) -----------------------------
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      -- Ships a prebuilt arm64 macOS netcoredbg binary in the repo — no build
      -- step needed. To upgrade it later (compiles from source, needs cmake +
      -- clang), run ./update.sh in the plugin dir manually.
      "Cliffback/netcoredbg-macOS-arm64.nvim",
    },
    config = function()
      require "configs.dap"
    end,
    keys = {
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP continue / start" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end,
        desc = "DAP conditional breakpoint",
      },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "DAP run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "DAP terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP toggle UI" },
      {
        "<leader>de",
        function() require("dapui").eval(nil, { enter = true }) end,
        mode = { "n", "v" },
        desc = "DAP eval expression",
      },
    },
  },

  -- Test runner: neotest + neotest-vstest (.NET / C# / F#) -------------------
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Nsidorenco/neotest-vstest",
    },
    config = function()
      require "configs.neotest"
    end,
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Test nearest" },
      {
        "<leader>tf",
        function() require("neotest").run.run(vim.fn.expand "%") end,
        desc = "Test file",
      },
      {
        "<leader>tp",
        function() require("neotest").run.run(vim.fn.getcwd()) end,
        desc = "Test project/suite",
      },
      {
        "<leader>td",
        function() require("neotest").run.run { strategy = "dap" } end,
        desc = "Debug nearest test",
      },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Test last" },
      { "<leader>tx", function() require("neotest").run.stop() end, desc = "Test stop" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
      {
        "<leader>to",
        function() require("neotest").output.open { enter = true, auto_close = true } end,
        desc = "Test output",
      },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Test output panel" },
    },
  },
}
