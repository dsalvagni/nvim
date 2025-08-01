return {
	{ "nvimtools/none-ls-extras.nvim" },
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
					null_ls.builtins.completion.spell,
          null_ls.builtins.formatting.rubocop,
          null_ls.builtins.diagnostics.rubocop,
          null_ls.builtins.formatting.pg_format,
          null_ls.builtins.formatting.sqlfmt,
					require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
				},
			})

			vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
		end,
	},
}
