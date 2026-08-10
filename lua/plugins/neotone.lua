return {
  "twenty9-labs/neotone.nvim",
  lazy = false,
  -- Lower priority than the colorschemes themselves (1000) so neotone runs
  -- after they are on the rtp, and after LazyVim applies its own colorscheme.
  priority = 900,
  config = function()
    require("neotone").setup({
      mode = "system",
      themes = {
        dark = "tokyonight-moon",
        light = "south",
      },
    })
  end,
}
