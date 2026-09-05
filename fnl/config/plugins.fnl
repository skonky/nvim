(local oil (require :config.plugins.oil))
(local mini (require :config.plugins.mini))
(local treesitter (require :config.plugins.treesitter))
(local conform (require :config.plugins.conform))
(local guess-indent (require :config.plugins.guess-indent))
(local rainbow (require :.config.plugins.rainbow))
(local colors (require :.config.plugins.colorscheme))

(fn setup []
  (oil.setup)
  (treesitter.setup)
  (mini.setup)
  (conform.setup)
  (rainbow.setup)
  (colors.setup)
  (guess-indent.setup))

{: setup}
