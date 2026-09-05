(vim.api.nvim_create_autocmd :FileType
                             {:pattern [:lua :fennel]
                              :callback #(vim.treesitter.start)})
