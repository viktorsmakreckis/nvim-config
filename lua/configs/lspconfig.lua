-- NvChad LSP defaults: global on_attach, capabilities, lua_ls, diagnostics.
require("nvchad.configs.lspconfig").defaults()

-- Servers that work out of the box with nvim-lspconfig defaults.
-- (lua_ls is already enabled by NvChad's defaults() above.)
-- (roslyn / C# is handled by roslyn.nvim, not here.)
local servers = {
  "html",
  "cssls",
  "jsonls",
  "vtsls", -- TypeScript / JavaScript / React / Next.js
  "eslint", -- JS/TS linting
  "tailwindcss", -- Tailwind (React / Svelte / Angular / Blazor)
  "emmet_language_server",
  "svelte", -- Svelte + SvelteKit
  "angularls", -- Angular
  "pyright", -- Python / FastAPI type checking
  "ruff", -- Python linting (and import sorting)
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers

-- ESLint: auto-fix on save -------------------------------------------------
-- Keep eslint's own on_attach (it registers the LspEslintFixAll command),
-- then add the save hook on top of it.
local eslint_base_on_attach = vim.lsp.config.eslint and vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
  on_attach = function(client, bufnr)
    if eslint_base_on_attach then
      eslint_base_on_attach(client, bufnr)
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspEslintFixAll",
    })
  end,
})

-- vtsls: inlay hints for TS/JS ---------------------------------------------
local vtsls_inlay = {
  inlayHints = {
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    variableTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    enumMemberValues = { enabled = true },
  },
}
vim.lsp.config("vtsls", {
  settings = {
    typescript = vtsls_inlay,
    javascript = vtsls_inlay,
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = { completion = { enableServerSideFuzzyMatch = true } },
    },
  },
})

-- pyright: let ruff own linting & import organization ----------------------
vim.lsp.config("pyright", {
  settings = {
    pyright = { disableOrganizeImports = true },
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- ruff: defer hover to pyright ---------------------------------------------
vim.lsp.config("ruff", {
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
})
