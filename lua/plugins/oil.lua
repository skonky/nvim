return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- oil hijacks netrw, so it has to be loaded before a directory argument is
    -- resolved (`nvim .`). Lazy-loading on keys would leave netrw in charge.
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open Parent Directory" },
      {
        "<leader>e",
        function()
          -- nil lets oil pick the current buffer's directory (cwd for unnamed buffers).
          require("oil").toggle_float()
        end,
        desc = "Explorer Oil (File Dir)",
      },
      {
        "<leader>E",
        function()
          require("oil").toggle_float(LazyVim.root())
        end,
        desc = "Explorer Oil (Root Dir)",
      },
      { "<leader>fe", "<leader>e", desc = "Explorer Oil (File Dir)", remap = true },
      { "<leader>fE", "<leader>E", desc = "Explorer Oil (Root Dir)", remap = true },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        -- `.git` is noise in every single directory; hidden dotfiles are not.
        is_always_hidden = function(name)
          return name == ".git"
        end,
      },
      keymaps = {
        -- oil's defaults for these collide with LazyVim: <C-s> is save (which is
        -- how you apply oil edits) and <C-h>/<C-l> are window navigation.
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in Vertical Split" },
        ["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in Horizontal Split" },
        ["<leader>rr"] = "actions.refresh",
        ["h"] = "actions.parent",
        ["l"] = "actions.select",
        ["q"] = "actions.close",
        ["Y"] = {
          desc = "Copy Path to Clipboard",
          callback = function()
            local entry = require("oil").get_cursor_entry()
            if entry then
              vim.fn.setreg("+", require("oil").get_current_dir() .. entry.name, "c")
            end
          end,
        },
        ["O"] = "actions.open_external",
      },
      float = {
        padding = 4,
        max_width = 120,
        max_height = 40,
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)

      -- Keep LSP clients and buffer names in sync when files move in the oil buffer.
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
          if event.data.err then
            return
          end
          for _, action in ipairs(event.data.actions) do
            -- oil reports `oil:///abs/path` URLs; Snacks wants plain paths. Other
            -- adapters (oil-ssh://) have no local path, so skip them.
            local src = action.type == "move" and action.src_url:match("^oil://(/.*)")
            local dest = src and action.dest_url:match("^oil://(/.*)")
            if dest then
              Snacks.rename.on_rename_file(src, dest)
            end
          end
        end,
      })
    end,
  },
}
