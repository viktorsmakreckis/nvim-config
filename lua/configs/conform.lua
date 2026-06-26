local prettier = { "prettierd", "prettier", stop_after_first = true }

local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    -- C#
    cs = { "csharpier" },

    -- JS / TS / React / Next / Svelte
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    svelte = prettier,
    vue = prettier,

    -- Markup / styles / data
    html = prettier,
    css = prettier,
    scss = prettier,
    less = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
    graphql = prettier,

    -- Python (FastAPI / Express tooling lives in JS above)
    python = { "ruff_format", "ruff_organize_imports" },
  },

  -- Format on save; falls back to the LSP formatter when no formatter is set
  -- (e.g. Razor/.razor formatting is handled by the roslyn LSP).
  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },
}

return options
