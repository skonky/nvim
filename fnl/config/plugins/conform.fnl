(vim.pack.add ["https://github.com/stevearc/conform.nvim"])

(local conform (require :conform))

; formatters by file type
(local ft {:lua [:stylua]
           :javascript [:biome]
           :javascriptreact [:biome]
           :typescript [:biome]
           :typescriptreact [:biome]
           :fennel [:fnlfmt]})

(fn on-save [_bufnr]
  {:timeout_ms 500 :lsp_format :never})

(fn setup []
  (conform.setup {:formatters_by_ft ft :format_on_save on-save}))

{: setup}
