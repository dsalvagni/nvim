return {
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "ruby", "html", "css", "javascript", "typescript", "lua", "yaml" },
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true
      })
  end
}
