(vim.api.nvim_create_autocmd :FileType
                             {:pattern [:lua
                                        :fennel
                                        :typescript
                                        :graphql
                                        :typescriptreact]
                              :callback #(vim.treesitter.start)})

(vim.api.nvim_create_autocmd :TextYankPost
                             {:desc "Highlight when yanking text"
                              :group (vim.api.nvim_create_augroup :highlight-yank
                                                                  {:clear true})
                              :callback #(vim.hl.on_yank)})
