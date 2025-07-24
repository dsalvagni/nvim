-- ~/.config/nvim/init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Set leader key
vim.g.mapleader = " "

-- Plugin setup
require("lazy").setup({
  -- Which key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function() 
      require('which-key').setup()
    end
  },
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = {
              "node_modules",
              ".git",
              ".DS_Store",
              "thumbs.db"
            },
            hide_by_pattern = {
              "*.tmp",
              "*.log",
            },
            never_show = {
              ".git",
              ".DS_Store",
              "thumbs.db"
            },
          },
        }
      })
    end
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules/.*",
            "%.git/.*",
            "tmp/.*",
            "log/.*",
            "vendor/.*",
            "coverage/.*",
            "%.lock",
            "%.log",
            "public/assets/.*",
            "public/packs/.*",
            "storage/.*"
          },
        },
        pickers = {
          find_files = {
            hidden = false,
            follow = true,
          },
          live_grep = {
            additional_args = function()
              return {"--hidden", "--glob", "!.git/*"}
            end
          },
        },
      })
      
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
  },

  -- Rails-specific plugin
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
  },

  -- Ruby support
  {
    "vim-ruby/vim-ruby",
    ft = { "ruby", "eruby" },
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "solargraph", "html", "cssls", "ts_ls", "eslint" }
      })

      local lspconfig = require('lspconfig')
      
      -- Ruby LSP
      lspconfig.ruby_lsp.setup{}
      
      -- HTML/CSS/JS/TS
      lspconfig.html.setup{}
      lspconfig.cssls.setup{}
      lspconfig.ts_ls.setup{}
      lspconfig.eslint.setup{}

      -- Global mappings
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- LSP mappings (only after LSP attaches)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "ruby", "html", "css", "javascript", "typescript", "lua", "yaml" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup()
    end
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  },

  -- Comment toggle
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end
  },
})

-- Custom Rails mappings
vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>")
vim.keymap.set("n", "<leader>r", ":Rails ")
vim.keymap.set("n", "<leader>rc", ":Rcontroller ")
vim.keymap.set("n", "<leader>rm", ":Rmodel ")
vim.keymap.set("n", "<leader>rv", ":Rview ")
vim.keymap.set("n", "<leader>rs", ":Rspec ")

-- Quick navigation between related files
vim.keymap.set("n", "<leader>a", ":A<CR>")  -- Alternate file (test <-> implementation)
vim.keymap.set("n", "<leader>R", ":R<CR>")  -- Related file


vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>ga", ":Git add %<CR>", { desc = "Git add current file" })
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>go", ":Git checkout ", { desc = "Git checkout branch" })

-- Niceties 
vim.keymap.set("n", "<leader>d", ":t.<CR>", { desc = "Duplicate line" })
vim.keymap.set("v", "<leader>d", ":t'><CR>", { desc = "Duplicate selection" })


