vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Let treesitter own syntax highlighting. LSP semantic tokens arrive ~1s
    -- after open and reclassify identifiers (imports, properties, namespaces)
    -- that treesitter had left as plain variables, which recolours the buffer
    -- in a visible "pop". Dropping the capability stops that second pass.
    client.server_capabilities.semanticTokensProvider = nil

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

-- Give only the LSP docs floats (hover / signature help) a solid background so
-- their text stays readable over the transparent editor. Other plugins' floats
-- keep the transparent NormalFloat; the window-local winhighlight below scopes
-- this to these floats. The chroma scheme defines HoverDoc/HoverDocBorder as a
-- distinct elevated panel; this only supplies a fallback when a colorscheme
-- hasn't set them, so it never clobbers the scheme's own definition.
-- local function set_hover_hl_fallback()
-- 	-- Only fill in when the colorscheme hasn't defined these, so chroma's own
-- 	-- definitions win. Panel colours fall back to Pmenu, the line to CursorLine.
-- 	local fallbacks = { HoverDoc = "Pmenu", HoverDocBorder = "Pmenu", HoverDocLine = "CursorLine" }
-- 	for group, target in pairs(fallbacks) do
-- 		if next(vim.api.nvim_get_hl(0, { name = group })) == nil then
-- 			vim.api.nvim_set_hl(0, group, { link = target })
-- 		end
-- 	end
-- end
-- set_hover_hl_fallback()
-- vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hover_hl_fallback })
--
-- local orig_open_floating_preview = vim.lsp.util.open_floating_preview
-- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
-- 	local bufnr, winid = orig_open_floating_preview(contents, syntax, opts, ...)
-- 	if winid and vim.api.nvim_win_is_valid(winid) then
-- 		-- style="minimal" turns cursorline off; re-enable it so the focused line
-- 		-- is highlighted, and scope all three groups to this window.
-- 		vim.wo[winid].winhighlight = "NormalFloat:HoverDoc,FloatBorder:HoverDocBorder,CursorLine:HoverDocLine"
-- 		vim.wo[winid].cursorline = true
-- 	end
-- 	return bufnr, winid
-- end

vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })

vim.keymap.set("n", "<leader>li", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
