(vim.pack.add ["https://github.com/nvim-mini/mini.nvim"])
(vim.pack.add ["https://github.com/nvim-mini/mini-git"])

(local mini-pick (require :mini.pick))
(local mini-completion (require :mini.completion))
(local mini-comment (require :mini.comment))
(local mini-diff (require :mini.diff))
(local mini-extra (require :mini.extra))

(fn setup []
  (mini-pick.setup {})
  (mini-completion.setup {})
  (mini-comment.setup {})
  (mini-diff.setup {})
  (mini-extra.setup {}))

{: setup}
