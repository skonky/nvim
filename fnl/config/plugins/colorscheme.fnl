(vim.pack.add ["https://github.com/ThorstenRhau/token"])

(local colors (require :token))
(local name :token-meridian)
(local opts {:plugins {:all true}})

(fn setup []
  (colors.setup opts)
  (vim.cmd.colorscheme name))

{: setup}
