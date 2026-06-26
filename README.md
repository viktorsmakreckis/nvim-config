# Neovim config — full-stack (.NET / Blazor + web + Python)

NvChad v2.5 based config tuned for: **C# / .NET 10+ / Blazor (Razor)**, **TypeScript /
JavaScript / React / Next.js**, **Angular**, **Svelte / SvelteKit**, **Python /
FastAPI**, and **Node / Express**.

- Completion: **blink.cmp** (nvim-cmp disabled via NvChad's official blink integration)
- C# / Blazor: **roslyn.nvim** — the same Roslyn server VS Code's C# Dev Kit uses.
  Razor/`.cshtml`/`.razor` works through Roslyn **cohosting** (the old `rzls.nvim`
  is deprecated, so it is intentionally not used here).
- Web/Python LSPs: vtsls, eslint, tailwindcss, emmet, svelte, angularls, pyright, ruff
- Formatting (on save): csharpier, prettierd/prettier, ruff, stylua
- Every server/formatter auto-installs on first launch via mason-tool-installer.

## 1. Prerequisites (macOS / Homebrew)

```bash
# Neovim 0.12+ is REQUIRED by roslyn.nvim
brew install neovim ripgrep fd git

# Toolchains
brew install dotnet        # .NET SDK 10+  (required for Blazor/Razor cohosting)
brew install node          # Node + npm (TS/React/Angular/Svelte/Express)
brew install python        # Python 3 (FastAPI projects use their own venv)

# A Nerd Font (icons) — then set it as your terminal font
brew install --cask font-jetbrains-mono-nerd-font
```

Verify versions:

```bash
nvim --version | head -1     # must be >= 0.12
dotnet --version             # must be >= 10
node --version
```

If `brew` gives you a Neovim older than 0.12, install the latest:
`brew install --HEAD neovim` (or grab a 0.12+ release build).

## 2. First launch

1. Run `nvim`. lazy.nvim bootstraps and installs all plugins; the base46 theme
   cache compiles. Let it finish, then **quit and reopen**.
2. mason-tool-installer installs every LSP/formatter automatically. Watch progress
   with `:Mason`. The **`roslyn`** package is large — first install can take a few
   minutes. (It comes from the `Crashdummyy` mason registry, already configured,
   because that build bundles the Razor extensions needed for Blazor.)
3. Reopen `nvim` once everything shows installed.

## 3. Using it per stack

- **C# / .NET / Blazor:** open the folder that contains your `.sln`
  (`cd MySolution && nvim .`). Roslyn attaches to `.cs` and to `.razor`/`.cshtml`.
  Multiple solutions? switch with `:Roslyn target`. `broad_search` is on, so
  sibling-dir solutions are found too.
- **React / Next.js:** vtsls + tailwindcss + eslint. Run `npm install` in the repo.
- **Angular:** angularls needs the project's own `@angular/language-server`
  (`npm install` in the project). It only attaches inside a real Angular workspace.
- **Svelte / SvelteKit:** the `svelte` server handles `.svelte`; vtsls handles `.ts`.
- **Python / FastAPI:** pyright (types) + ruff (lint/format/imports). Activate your
  venv before launching `nvim` so the right interpreter is picked up.

## 4. Good to know

- **Format on save** is enabled in `lua/configs/conform.lua`. Remove the
  `format_on_save` block there to disable it.
- **ESLint** auto-fixes on save.
- Add/adjust LSP servers in `lua/configs/lspconfig.lua`; installed tools in
  `lua/plugins/init.lua` (the `mason-tool-installer` block).
- Keybinds are NvChad defaults — leader is `Space`. `<Space>th` theme picker,
  `<Space>ff` find files, `gd` go to definition, `<Space>ca` code action.
  `:NvCheatsheet` lists everything.
- **One cleanup step:** a stray `.git/` folder was left in `~/.config/nvim` during
  setup. Remove it: `rm -rf ~/.config/nvim/.git`

## 5. Debugging (.NET)

nvim-dap + nvim-dap-ui + netcoredbg.

- On **Apple Silicon** there is no upstream netcoredbg build, so it's supplied by
  `netcoredbg-macOS-arm64.nvim`, which ships a prebuilt binary in the plugin —
  nothing to compile, it just works after `:Lazy sync`. To upgrade it later (this
  compiles from source, needs `cmake` + `clang`), run `./update.sh` inside
  `~/.local/share/nvim/lazy/netcoredbg-macOS-arm64.nvim`.
- On Intel macOS / Linux, netcoredbg is installed via mason automatically.

To debug: build your project (`dotnet build`), open a `.cs` file, set a breakpoint
(`<leader>db`), then `<leader>dc` to launch — you'll be prompted for the `.dll`
(defaults to `bin/Debug/...`). A `.env` in the project root is loaded automatically.

| Key | Action |
| --- | --- |
| `<leader>dc` | Continue / start |
| `<leader>db` / `<leader>dB` | Toggle / conditional breakpoint |
| `<leader>di` `<leader>do` `<leader>dO` | Step into / over / out |
| `<leader>dr` | Toggle REPL |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Eval expression (normal/visual) |
| `<leader>dl` / `<leader>dt` | Run last / terminate |

## 6. Testing

neotest with the **neotest-vstest** adapter (VSTest / Microsoft.Testing.Platform).
Supports xUnit / NUnit / MSTest / TUnit, C# and F#, no extra deps beyond the dotnet
SDK. It picks up your `.sln` automatically (asks if there are several).

| Key | Action |
| --- | --- |
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run tests in file |
| `<leader>tp` | Run whole project/suite |
| `<leader>td` | Debug nearest test (via nvim-dap) |
| `<leader>tl` / `<leader>tx` | Run last / stop |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` / `<leader>tO` | Output float / output panel |

Roslyn test code-lens is also on, so run/references hints appear above test methods.

(Want pytest for your FastAPI projects too? Adding `nvim-neotest/neotest-python`
+ `debugpy` is a small follow-up — just ask.)

## Layout

```
init.lua                     -- NvChad + lazy bootstrap
lua/chadrc.lua               -- theme / UI options
lua/options.lua              -- editor options
lua/mappings.lua             -- key mappings
lua/plugins/init.lua         -- plugins: blink, mason, roslyn, treesitter, dap, neotest
lua/configs/lspconfig.lua    -- web + python language servers
lua/configs/conform.lua      -- formatters + format-on-save
lua/configs/dap.lua          -- .NET debugging (netcoredbg)
lua/configs/neotest.lua      -- test runner
```
