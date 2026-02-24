vim.keymap.set("n", "K", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local encoding = clients[1] and clients[1].offset_encoding or "utf-16"
	local params = vim.lsp.util.make_position_params(0, encoding)
	vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result)
		if not result or not result.contents then
			return
		end

		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		lines = vim.split(table.concat(lines, "\n"), "\n", { trimempty = true })
		if vim.tbl_isempty(lines) then
			return
		end

		vim.schedule(function()
			for i, line in ipairs(lines) do
				line = line:gsub("%[([^%]]+)%]%(file://[^%)]+%)", "%1")
				line = line:gsub("%[([^%]]+)%]%((.-)%)", "%1 (%2)")
				lines[i] = line
			end

			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].filetype = "markdown"
			require("markview.actions").attach(buf)

			local height = math.min(#lines, 15)
			local win = vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				row = vim.o.lines - height - 2,
				col = 0,
				width = vim.o.columns,
				height = height,
				style = "minimal",
				border = "single",
			})

			vim.bo[buf].modifiable = false
			vim.bo[buf].bufhidden = "wipe"
			vim.wo[win].wrap = true
			vim.wo[win].linebreak = true
			vim.wo[win].conceallevel = 3
			vim.wo[win].concealcursor = "nvic"

			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })

			vim.api.nvim_create_autocmd("BufLeave", {
				buffer = buf,
				once = true,
				callback = function()
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_close(win, true)
					end
				end,
			})
		end)
	end)
end)
