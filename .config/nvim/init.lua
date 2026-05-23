-- ~/.config/nvim/init.lua

-- Install Plugin Manager (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Core Editor Settings
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- Install Essential Plugins
require("lazy").setup({
  -- LSP
  { "neovim/nvim-lspconfig" },

  -- Auto install LSP
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Treesitter (syntax)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Use pcall to prevent the whole config from breaking if it's not installed yet
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then return end

      configs.setup({
        ensure_installed = { "lua", "python", "go", "javascript" },
        highlight = { enable = true },
      })
    end,
  },

  -- File explorer
  { "nvim-tree/nvim-tree.lua" },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Statusline
  { "nvim-lualine/lualine.nvim" },

  -- Theme
  { "folke/tokyonight.nvim" },

  -- Auto format
  { "stevearc/conform.nvim" },

  -- Make Neovim answer to the mouse
  { url = "https://codeberg.org/andyg/leap.nvim" },

  -- Debugging
  { "mfussenegger/nvim-dap" },

  -- Lazygit
  { "jesseduffield/lazygit" },
})

-- LSP setup (Native Neovim 0.11+ style)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

-- Define the configurations
local servers = { "pyright", "ts_ls", "gopls" }

for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    install = true, -- Auto-install via native framework if supported
    capabilities = capabilities,
    on_attach = on_attach,
  })
end

-- Start the servers
vim.lsp.enable(servers)


-- Autocompletion (nvim-cmp)
local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})

-- Telescope (your productivity multiplier)
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)

-- Keybindings for LSP (critical)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

-- Git Integration
require("gitsigns").setup()

-- File Explorer
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Statusline + Theme
require("lualine").setup()
vim.cmd.colorscheme("tokyonight")

-- Autoformating
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
})

vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true })
end)

---- format on savfe
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    require("conform").format({ async = false })
  end,
})

-- Diagnostics UX (make errors actionable)
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  float = { border = "rounded" },
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- File switching optimization
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")

-- Debugging Python
local dap = require("dap")

dap.adapters.python = {
  type = "executable",
  command = "python",
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    program = "${file}",
  },
}

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dc", dap.continue)

-- Bind for LazyGit
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>")

-- Tmux
vim.keymap.set("n", "<leader>t", ":terminal<CR>")

-- Advanced LSP Usage
-- gr → references
-- gi → implementation
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)

