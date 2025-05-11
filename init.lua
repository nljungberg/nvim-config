-- init.lua
vim.g.loaded_lua_ftplugin = 1

print("Init.lua loaded...")

-- 1) Leader keys
vim.g.mapleader = " "            -- Use space as the leader key
vim.g.maplocalleader = " "

-- 2) Enable true color support (required for many themes)
vim.opt.termguicolors = true

-- 3) Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim plugin manager...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 4) Plugin setup via lazy.nvim
require("lazy").setup({
  -- 1) File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeToggle<CR>", {
        desc = "Toggle file explorer",
      })
    end,
  },

  -- 2) Fuzzy finder (Telescope + fzf-native)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    build = "make",
    cond  = vim.fn.executable("make") == 1,
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", "%.git/" },
        },
      })
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files,  { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,   { desc = "Grep in files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "List buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags,   { desc = "Help tags" })
    end,
  },

  
  -- 3) Autocompletion engine + LSP ↔ cmp bridge
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- 4) LSP installer + config
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "folke/neodev.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup { ensure_installed = { "clangd", "pyright", "lua_ls" } }
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(client, bufnr)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        bufmap("n", "gd", vim.lsp.buf.definition,   "Go to definition")
        bufmap("n", "gD", vim.lsp.buf.declaration,  "Go to declaration")
        bufmap("n", "gr", vim.lsp.buf.references,   "Find references")
        bufmap("n", "K",  vim.lsp.buf.hover,        "Hover docs")
        bufmap("n", "<leader>rn", vim.lsp.buf.rename,      "Rename symbol")
        bufmap("n", "[d", vim.diagnostic.goto_prev,        "Prev diagnostic")
        bufmap("n", "]d", vim.diagnostic.goto_next,        "Next diagnostic")
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        bufmap("n", "<leader>sd", vim.diagnostic.open_float, "Show diagnostics")
      end
      lspconfig.clangd .setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig.pyright.setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities, settings = { Lua = { workspace = { checkThirdParty = false } } } })
    end,
  },

  -- 5) Treesitter (syntax & indent)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight    = { enable = true },
        indent       = { enable = true },
      })
    end,
  },

  -- 6) Dracula theme
  {
    "doums/darcula",
    config = function()
      vim.cmd("colorscheme darcula")
    end,
  },

	-- Autocompletion
	{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",   -- LSP source for nvim-cmp
    "hrsh7th/cmp-buffer",     -- buffer word completion
    "hrsh7th/cmp-path",       -- path completion
    "saadparwaiz1/cmp_luasnip", -- snippet completions
    "L3MON4D3/LuaSnip",       -- snippet engine
    "rafamadriz/friendly-snippets" -- a bunch of snippets to use
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    require("luasnip.loaders.from_vscode").lazy_load()  -- load snippets

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)  -- expand snippet
        end
      },
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, {"i","s"}),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, {"i","s"}),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),  -- Enter to confirm
        ["<C-e>"] = cmp.mapping.abort()
      }),
      sources = cmp.config.sources({
        { name = "copilot" },    -- GitHub Copilot (if using copilot-cmp)
        { name = "nvim_lsp" },   -- LSP completions
        { name = "luasnip" },    -- Snippets
        { name = "buffer" }, 
        { name = "path" }
      })
    })
  end
},

-- Git integration	
{
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup()
    -- Keybindings for git actions
    vim.keymap.set("n", "<leader>gp", "<CMD>Gitsigns preview_hunk<CR>", { desc = "Preview Git hunk" })
    vim.keymap.set("n", "<leader>gb", "<CMD>Gitsigns toggle_current_line_blame<CR>", { desc = "Blame current line" })
  end
},
{ "tpope/vim-fugitive" },
{ "tpope/vim-rhubarb" },


-- Github Copilot
{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot", event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = { enabled = true },  -- we’ll use copilot-cmp for suggestions
      panel = { enabled = false },
    })
  end
},
{
  "zbirenbaum/copilot-cmp",
  dependencies = "zbirenbaum/copilot.lua",
  config = function()
    require("copilot_cmp").setup()
  end
},

	  -- Misc Utilities
  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup{} end
  },
  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end
  },
  {
    "folke/which-key.nvim",
    config = function() require("which-key").setup() end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight", section_separators = "", component_separators = "" }
      })
    end
  },

-- CopilotChat:
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "zbirenbaum/copilot.lua",      -- your completion engine
      { "nvim-lua/plenary.nvim", branch = "master" },  -- HTTP + async helpers
    },
    build = "make tiktoken",        -- compile the tokenizer (Linux/macOS)
    opts = {
      -- any CopilotChat-specific config here (see docs)
    },
    -- you can lazy‑load on commands:
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatToggle",
    },
  },



})

-- 7) UI settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true


vim.keymap.set("n", "<C-z>", "u", { desc = "Undo last change" })
vim.keymap.set("n", "<C-S-z>", "<C-r>", { desc = "Redo last change" })
