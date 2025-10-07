(local vim _G.vim)
(local {: set-opts : set-globals : set-keymap} (require :utils))


(set-opts {
	  :termguicolors true
	  :number true
	  :relativenumber true
	  :signcolumn "yes"
	  :cursorline true
	  :scrolloff 10
	  :splitright true
	  :splitbelow true
	  :ignorecase true
	  :smartcase true
	  :inccommand "split"
	  :swapfile false
	  :mouse "a"
	  :breakindent true
	  :undofile true
	  :confirm true
	  :updatetime 250
	  :timeoutlen 300
	  :list true
	  :listchars {:tab "» " :trail "·" :nbsp "␣"}
	  :foldenable true
	  :foldlevelstart 99
	  :foldlevel 99
	  :foldmethod "indent" })

(set-globals {
	     :neovide_theme "auto"
	     :neovide_padding_left 50
	     :neovide_padding_right 50
	     :neovide_opacity 0.85
	     :neovide_window_blurred true
	     :neovide_padding_top 50
	     :neovide_padding_bottom 50
	     :mapleader " "
	     :maplocalleader " "})

(set vim.g.conjure#mapping#doc_word false)
(vim.schedule (fn [] 
	(vim.opt.clipboard:append "unnamedplus")))

;; Basic keymaps
(set-keymap :n "<Esc>" "<cmd>nohlsearch<CR>")
(set-keymap :n "<C-s>" ":write<CR>" {:desc "Save"})
(set-keymap :n "<leader>so" ":update<CR> :source<CR>" {:desc "Source config"})
(set-keymap :n "<leader>bd" "<cmd>bdelete<CR>" {:desc "Delete buffer"})

;; Navigation
(set-keymap :n "<C-d>" "<C-d>zz" {:desc "Scroll down and center"})
(set-keymap :n "<C-u>" "<C-u>zz" {:desc "Scroll up and center"})
(set-keymap :n "<C-h>" "<C-w><C-h>" {:desc "Move focus to left window"})
(set-keymap :n "<C-l>" "<C-w><C-l>" {:desc "Move focus to right window"})
(set-keymap :n "<C-j>" "<C-w><C-j>" {:desc "Move focus to lower window"})
(set-keymap :n "<C-k>" "<C-w><C-k>" {:desc "Move focus to upper window"})

;; Folding
(set-keymap :n "-" ":foldclose<CR>" {:desc "Close fold"})
(set-keymap :n "+" ":foldopen<CR>" {:desc "Open fold"})

;; Visual mode
(set-keymap :v "<C-j>" ":m '>+1<CR>gv=gv" {:desc "Move selection down"})
(set-keymap :v "<C-k>" ":m '<-2<CR>gv=gv" {:desc "Move selection up"})
(set-keymap :v "<" "<gv" {:desc "Indent left and reselect"})
(set-keymap :v ">" ">gv" {:desc "Indent right and reselect"})


;; Better J behavior
(set-keymap :n "J" "mzJ`z" {:desc "Join lines and keep cursor position"})

;; Terminal
(set-keymap :t "<Esc><Esc>" "<C-\\><C-n>" {:desc "Exit terminal mode"})

;; LSP
(set-keymap :n "<leader>q" vim.diagnostic.setloclist {:desc "Open diagnostic quickfix list"})
(set-keymap :n "<leader>lf" vim.lsp.buf.format {:desc "Format buffer"})
(set-keymap :n "<leader>ca" vim.lsp.buf.code_action {:desc "Code action"})
(set-keymap :n "gD" vim.lsp.buf.type_definition {:desc "Go to declaration"})
(set-keymap :n "gd" vim.lsp.buf.definition {:desc "Go to declaration"})
(set-keymap :n "<leader>rn" vim.lsp.buf.rename {:desc "Rename symbol"})

;; Plugin keymaps
(set-keymap :n "<leader>gg" ":Neogit<CR>" {:desc "Open Neogit"})
(set-keymap :n "<leader>e" ":Oil<CR>" {:desc "Open Oil file explorer"})
(set-keymap :n "<leader>pp" "<cmd>NeovimProjectDiscover<CR>" {:desc "Discover projects"})
(set-keymap :n "<leader>sf" ":Pick files<CR>" {:desc "Search files"})
(set-keymap :n "<leader>sg" ":Pick grep_live<CR>" {:desc "Live grep"})
(set-keymap :n "<leader>/" ":Pick buf_lines<CR>" {:desc "Live grep"})
(set-keymap :n "<leader><leader>" ":Pick buffers<CR>" {:desc "Search buffers"})
(set-keymap :n "<leader>gs" ":Pick git_hunks<CR>" {:desc "Git hunks"})
(set-keymap :n "<leader>km" ":Pick keymaps<CR>" {:desc "Show keymaps"})
(set-keymap :n "<D-x>" ":Pick commands<CR>" {:desc "See all commands"})

;; Terminal tabs
(set-keymap :n "<leader>td" ":tabclose<CR>" {:desc "Close terminal tab"})

;; ============================================================================
;; PLUGIN BOOTSTRAP
;; ============================================================================
(local plugins [
		"https://github.com/rktjmp/hotpot.nvim"
		"https://github.com/supermaven-inc/supermaven-nvim"
		"https://github.com/lewis6991/gitsigns.nvim"
		"https://github.com/stevearc/oil.nvim"
		"https://github.com/stevearc/conform.nvim"
		"https://github.com/NMAC427/guess-indent.nvim"
		"https://github.com/neovim/nvim-lspconfig"
		"https://github.com/ibhagwan/fzf-lua"
		"https://github.com/coffebar/neovim-project"
		"https://github.com/Shatur/neovim-session-manager"
		"https://github.com/nvim-lua/plenary.nvim"
		"https://github.com/echasnovski/mini.nvim"
		"https://github.com/nvim-treesitter/nvim-treesitter"
		"https://github.com/NeogitOrg/neogit"
		"https://github.com/navarasu/onedark.nvim"
		"https://github.com/mistweaverco/kulala.nvim"
		"https://github.com/twenty9-labs/frisch.nvim"
		"https://github.com/Olical/conjure"])

(local pack-path (.. (vim.fn.stdpath :data) "/pack/plugins/start"))
(vim.fn.mkdir pack-path :p)

;; Bootstrap: install missing plugins
(each [_ url (ipairs plugins)]
  (local name (url:match "([^/]+)$"))
  (local plugin-dir (.. pack-path "/" name))
  (when (= (vim.fn.isdirectory plugin-dir) 0)
    (print (.. "Installing " name "..."))
    (vim.fn.system ["git" "clone" "--depth" "1" url plugin-dir])))

(vim.pack.add plugins)

;; ============================================================================
;; PLUGIN CONFIGURATION
;; ============================================================================
((. (require :kulala) :setup) 
 {:ft [:http]
  :global_keymaps {"Send request" ["<C-c><C-c>"
                                   (fn [] ((. (require :kulala) :run)))
                                   {:mode [:n :v]
                                    :desc "Send request"}]
                   "Send all requests" ["<leader>Ra"
                                        (fn [] ((. (require :kulala) :run_all)))
                                        {:mode [:n :v]
                                         :ft :http}]
                   "Replay the last request" ["<leader>Rr"
                                               (fn [] ((. (require :kulala) :replay)))
                                               {:ft [:http :rest]}]
                   "Find request" false}})
((. (require :supermaven-nvim) :setup) {})
((. (require :mini.icons) :setup))
((. (require :mini.comment) :setup))
((. (require :mini.surround) :setup))
((. (require :mini.pairs) :setup))
((. (require :mini.pick) :setup) 
 {:mappings {:choose_all {:char "<C-q>"
                          :func (fn []
                                  (local miniPick (require :mini.pick))
                                  (local mappings (. (miniPick.get_picker_opts) :mappings))
                                  (vim.api.nvim_input (.. mappings.mark_all 
                                                          mappings.choose_marked)))}}
  :window {:config (fn []
                     (local height (math.floor (* vim.o.lines 0.9)))
                     (local width (math.floor (* vim.o.columns 0.9)))
                     {:anchor "NW"
                      :height height
                      :width width
                      :row (math.floor (/ (- vim.o.lines height) 2))
                      :col (math.floor (/ (- vim.o.columns width) 2))})}})

((. (require :mini.extra) :setup))
((. (require :mini.completion) :setup))

((. (require :conform) :setup)
 {:format_on_save {:timeout_ms 500
                   :lsp_format :fallback}
  :formatters_by_ft {:lua [:stylua]
                     :javascript [:prettierd]
                     :typescript [:prettierd]
                     :typescriptreact [:prettierd]
                     :json [:prettierd]}})
((. (require :oil) :setup)
 {:columns [:icon]})

((. (require :guess-indent) :setup)
 {:auto_cmd true})

((. (require :neovim-project) :setup)
 {:projects ["~/.config"
             "~/.config/nvim"
             "~/.config/ghostty/"
	     "~/scripts/kulala"
             "~/Code/adhese/cloud"
             "~/Code/adhese/mcb-frontend"
             "~/Code/adhese/sdk_typescript.git"
             "~/Code/adhese/gambit-design-system"
	     "~/FennelProjects/second-game"
             "~/Code/adhese/playwright-tests"]
  :picker {:type :fzf-lua}})

((. (require :nvim-treesitter.configs) :setup)
 {:highlight {:enable true}
  :ensure_installed [:lua
                     :markdown
                     :markdown_inline
                     :typescript
                     :javascript
                     :graphql
                     :yaml
                     :json
                     :css
                     :html
                     :fennel
                     :clojure]})

((. (require :gitsigns) :setup)
 {:on_attach (fn [bufnr]
               (local gs package.loaded.gitsigns)
               (vim.keymap.set :n "]g" gs.next_hunk {:buffer bufnr :desc "Next git hunk"})
               (vim.keymap.set :n "[g" gs.prev_hunk {:buffer bufnr :desc "Previous git hunk"}))})

(require :neogit)

(vim.cmd "colorscheme nord")

;; ============================================================================
;; LSP CONFIGURATION
;; ============================================================================
(vim.lsp.enable [:lua_ls :ts_ls :tailwindcss :eslint :fennel_language_server])

;; ============================================================================
;; TERMINAL MANAGEMENT
;; open a terminal in a new tab with <leader>tt
;; ============================================================================

(local term_numbers {})

(vim.keymap.set :n "<leader>tt" 
  (fn []
    (var num 1)
    (while (. term_numbers num)
      (set num (+ num 1)))
    (vim.cmd :tabnew)
    (vim.cmd :term)
    (vim.cmd (.. "file term-" num))
    (local buf (vim.api.nvim_get_current_buf))
    (tset vim.bo buf :buflisted false)
    (tset term_numbers num buf)
    (vim.api.nvim_create_autocmd :BufHidden
      {:buffer buf
       :once true
       :callback (fn []
                   (tset term_numbers num nil)
                   (vim.schedule (fn []
                                   (when (vim.api.nvim_buf_is_valid buf)
                                     (vim.api.nvim_buf_delete buf {:force true})))))}))
  {:desc "Open terminal in new tab"})

;; ============================================================================
;; CUSTOM TABLINE
;; ============================================================================
(set vim.o.tabline "%!v:lua.MyTabLine()")

(fn _G.MyTabLine []
  (var title "")
  (for [i 1 (vim.fn.tabpagenr "$")]
    (local buflist (vim.fn.tabpagebuflist i))
    (local winnr (vim.fn.tabpagewinnr i))
    (local bufnr (. buflist winnr))
    (local bufname (vim.fn.bufname bufnr))

    ;; Highlight
    (if (= i (vim.fn.tabpagenr))
        (set title (.. title "%#TabLineSel#"))
        (set title (.. title "%#TabLine#")))

    ;; Tab number
    (set title (.. title " " i " "))

    ;; Filename only (no path)
    (if (not= bufname "")
        (set title (.. title (vim.fn.fnamemodify bufname ":t")))
        (set title (.. title "[No Name]")))

    (set title (.. title " ")))

  (set title (.. title "%#TabLineFill#%T"))
  title)

;; Need this for kulala to have lsp and syntax highlighting
(vim.filetype.add {:extension {:http "http"}})

;; Prevent write issues with typescript-language-server
(set vim.env.TMPDIR (vim.fn.expand "~/.cache/nvim/tmp"))
(vim.fn.mkdir vim.env.TMPDIR :p)
