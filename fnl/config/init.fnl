(local options (require :config.options))
(local keymaps (require :config.keymaps))
(local plugins (require :config.plugins))

(require :config.lsp)
(require :config.autocmd)

(fn setup []
  (options.setup)
  (plugins.setup)
  (keymaps.setup))

{: setup}
