; lsp config
(vim.pack.add ["https://github.com/neovim/nvim-lspconfig"])

; fennel
(vim.lsp.config :fennel_language_server
                {:cmd [:fennel-language-server]
                 :filetypes [:fennel]
                 :root_markers [:.nfnl.fnl :.git]
                 :settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                                     :diagnostics {:globals [:vim]}}}})

(vim.lsp.enable :fennel_language_server)

; typescript
(vim.lsp.config :typescript
                {:cmd [:vtsls :--stdio]
                 :filetypes [:typescript :typescriptreact]})

(vim.lsp.enable :typescript)

; tailwindcss
(vim.lsp.config :tailwindcss
                {:cmd [:tailwindcss-language-server]
                 :filetypes [:typescriptreact]})

(vim.lsp.enable :tailwindcss)

; graphql
(vim.lsp.config :graphql {:filetypes [:graphql]})

(vim.lsp.enable :graphql)
