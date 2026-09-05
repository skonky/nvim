(vim.pack.add ["https://github.com/nvim-mini/mini.nvim"])
(vim.pack.add ["https://github.com/nvim-mini/mini-git"])
(vim.pack.add ["https://github.com/nvim-mini/mini.statuscolumn"])
(vim.pack.add ["https://github.com/nvim-mini/mini.clue"])

(local mini-pick (require :mini.pick))
(local mini-completion (require :mini.completion))
(local mini-comment (require :mini.comment))
(local mini-diff (require :mini.diff))
(local mini-extra (require :mini.extra))
(local mini-starter (require :mini.starter))
(local mini-notify (require :mini.notify))
(local mini-tabline (require :mini.tabline))
(local mini-hipatterns (require :mini.hipatterns))
(local mini-icons (require :mini.icons))
(local mini-statusline (require :mini.statusline))
(local mini-indentscope (require :mini.indentscope))
(local mini-statuscolumn (require :mini.statuscolumn))
(local mini-cursorword (require :mini.cursorword))
(local mini-clue (require :mini.clue))
(local mini-cmdline (require :mini.cmdline))
(local mini-trailspace (require :mini.trailspace))

(fn setup []
  (mini-pick.setup {})
  (mini-completion.setup {})
  (mini-comment.setup {})
  (mini-diff.setup {})
  (mini-starter.setup {})
  (mini-notify.setup {})
  (mini-tabline.setup {})
  (mini-hipatterns.setup {})
  (mini-trailspace.setup {})
  (mini-statuscolumn.setup {})
  (mini-indentscope.setup {})
  (mini-clue.setup {:triggers [{:mode [:n :x] :keys :<leader>}]
                    :clues [{:mode :n :keys :<Leader>c :desc :+Code}
                            {:mode :n :keys :<Leader>g :desc :+Git/Goto}
                            {:mode :n :keys :<Leader>r :desc :+Rename}
                            {:mode :n :keys :<Leader>s :desc :+Search}
                            mini-clue.gen_clues.square_brackets
                            mini-clue.gen_clues.builtin_completion
                            mini-clue.gen_clues.g
                            mini-clue.gen_clues.windows]})
  (mini-cmdline.setup {})
  (mini-icons.setup {})
  (mini-statusline.setup {})
  (mini-cursorword.setup {})
  (mini-extra.setup {}))

{: setup}
