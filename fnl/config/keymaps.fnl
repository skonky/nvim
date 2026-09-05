(fn setup []
  (vim.keymap.set :n :<C-d> :<C-d>zz)
  (vim.keymap.set :n :<C-u> :<C-u>zz)
  (vim.keymap.set :n :<C-h> :<C-w><C-h>)
  (vim.keymap.set :n :<C-l> :<C-w><C-l>)
  (vim.keymap.set :n :<C-j> :<C-w><C-j>)
  (vim.keymap.set :n :<C-k> :<C-w><C-k>)
  (vim.keymap.set :v :<C-j> ":m '>+1<CR>gv=gv")
  (vim.keymap.set :v :<C-k> ":m '<-2<CR>gv=gv")
  (vim.keymap.set :n "-" ":foldclose<CR>")
  (vim.keymap.set :n "+" ":foldopen<CR>")
  (vim.keymap.set :v ">" :>gv)
  (vim.keymap.set :v "<" :<gv)
  (vim.keymap.set :n :<leader>ca vim.lsp.buf.code_action)
  (vim.keymap.set :n :<leader>gd vim.lsp.buf.declaration)
  (vim.keymap.set :n :<leader>rn vim.lsp.buf.rename)
  (vim.keymap.set :n :<leader>e :<cmd>Oil<CR>)
  (vim.keymap.set :n :<leader>sf "<cmd>Pick files<CR>")
  (vim.keymap.set :n :<leader>sg "<cmd>Pick grep_live<CR>")
  (vim.keymap.set :n :<leader><leader> "<cmd>Pick buffers<CR>")
  (vim.keymap.set :n :<leader>gs "<cmd>Pick git_hunks<CR>")
  (vim.keymap.set :n :<leader>q vim.diagnostic.setloclist
                  {:desc "Open diagnostic quickfix list"}))

(vim.keymap.set :n :<Esc> :<cmd>nohlsearch<CR>)

{: setup}
