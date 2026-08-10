return {
  "pwntester/octo.nvim",
  opts = {
    -- LazyVim's extra turns this on, but Projects v2 queries need the
    -- `read:project` scope and the gh CLI token doesn't have it. Granting it
    -- means `gh auth refresh`, which rotates the token forge reads from
    -- ~/.authinfo. Not worth it for a feature we don't use.
    default_to_projects_v2 = false,
  },
}
