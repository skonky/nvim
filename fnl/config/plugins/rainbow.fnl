(vim.pack.add ["https://github.com/hiphish/rainbow-delimiters.nvim"])
(local rainbow (require :rainbow-delimiters.setup))

(fn setup []
  (rainbow.setup {}))

{: setup}
