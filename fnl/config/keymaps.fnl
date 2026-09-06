(fn setup []
  (vim.keymap.set :n :<C-d> :<C-d>zz
                  {:desc "Scroll down half page, center cursor"})
  (vim.keymap.set :n :<C-u> :<C-u>zz
                  {:desc "Scroll up half page, center cursor"})
  (vim.keymap.set :n :<C-h> :<C-w><C-h> {:desc "Go to left window"})
  (vim.keymap.set :n :<C-l> :<C-w><C-l> {:desc "Go to right window"})
  (vim.keymap.set :n :<C-j> :<C-w><C-j> {:desc "Go to lower window"})
  (vim.keymap.set :n :<C-k> :<C-w><C-k> {:desc "Go to upper window"})
  (vim.keymap.set :v :<C-j> ":m '>+1<CR>gv=gv" {:desc "Move selection down"})
  (vim.keymap.set :v :<C-k> ":m '<-2<CR>gv=gv" {:desc "Move selection up"})
  (vim.keymap.set :n "-" ":foldclose<CR>" {:desc "Close fold"})
  (vim.keymap.set :n "+" ":foldopen<CR>" {:desc "Open fold"})
  (vim.keymap.set :v ">" :>gv {:desc "Indent, keep selection"})
  (vim.keymap.set :v "<" :<gv {:desc "Dedent, keep selection"})
  (vim.keymap.set :n :<leader>ca vim.lsp.buf.code_action {:desc "Code action"})
  (vim.keymap.set :n :<leader>gd vim.lsp.buf.declaration
                  {:desc "Go to declaration"})
  (vim.keymap.set :n :<leader>rn vim.lsp.buf.rename {:desc "Rename symbol"})
  (vim.keymap.set :n :<leader>e :<cmd>Oil<CR> {:desc "Open file explorer"})
  (vim.keymap.set :n :<leader>sf "<cmd>Pick files<CR>" {:desc "Search files"})
  (vim.keymap.set :n :<leader>sg "<cmd>Pick grep_live<CR>"
                  {:desc "Search by grep"})
  (vim.keymap.set :n :<leader><leader> "<cmd>Pick buffers<CR>"
                  {:desc "Find buffer"})
  (vim.keymap.set :n :<leader>gs "<cmd>Pick git_hunks<CR>"
                  {:desc "Search git hunks"})
  (vim.keymap.set :n :<leader>q vim.diagnostic.setloclist
                  {:desc "Open diagnostic quickfix list"})
  (vim.keymap.set :n :<Esc> :<cmd>nohlsearch<CR>
                  {:desc "Clear search highlight"}))

{: setup}
