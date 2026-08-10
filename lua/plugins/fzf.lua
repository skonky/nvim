return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    opts.keymap = opts.keymap or {}
    opts.keymap.fzf = opts.keymap.fzf or {}
    -- "narrow": keep only currently-matching entries as the new candidate list.
    -- fzf has no native action for this, so we abuse select-all -> reload from
    -- the selection ({+}) -> reset query/selection.
    opts.keymap.fzf["ctrl-space"] =
      "select-all+reload(printf '%s\\n' {+})+clear-query+deselect-all+first"
    return opts
  end,
}
