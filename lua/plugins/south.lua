return {
  "arnauKL/south.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- Optional configuration goes here
    -- No colorscheme call here: neotone picks between south and tokyonight
    -- based on the macOS appearance.
    require("south").setup({
      transparent = false,
    })
  end,
}
