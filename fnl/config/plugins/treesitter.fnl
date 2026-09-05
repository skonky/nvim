(vim.pack.add ["https://github.com/nvim-treesitter/nvim-treesitter"])
(local nvim-treesitter (require :nvim-treesitter))

(local lang [:fennel
             :typescript
             :tsx
             :markdown
             :graphql
             :css
             :html
             :lua
             :yaml
             :javascript])

(fn setup []
  (nvim-treesitter.setup {})
  (nvim-treesitter.install lang))

{: setup}
