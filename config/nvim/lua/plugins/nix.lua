return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}

      if vim.fn.executable("statix") == 0 then
        opts.linters_by_ft.nix = vim.tbl_filter(function(linter)
          return linter ~= "statix"
        end, opts.linters_by_ft.nix or {})
      end
    end,
  },
}
