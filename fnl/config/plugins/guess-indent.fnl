(vim.pack.add ["https://github.com/nmac427/guess-indent.nvim"])
(local guess-indent (require :guess-indent))

(fn setup []
  (guess-indent.setup {}))

{: setup}
