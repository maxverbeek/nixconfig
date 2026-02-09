local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt

-- Convert arrow function between concise and block body formats
-- Handles: (args) => value <-> (args) => { return value }
local function toggle_arrow_function()
	return d(1, function()
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		local row = cursor_pos[1] - 1 -- 0-indexed
		local col = cursor_pos[2]

		-- Get the parser for the current buffer
		local parser = vim.treesitter.get_parser(0)
		local tree = parser:parse()[1]
		local root = tree:root()

		-- Find the arrow function node at cursor
		local node = root:descendant_for_range(row, col, row, col)

		-- Traverse up to find arrow_function node
		while node do
			if node:type() == "arrow_function" then
				break
			end
			node = node:parent()
		end

		if not node or node:type() ~= "arrow_function" then
			return sn(nil, { i(1, "-- No arrow function found at cursor") })
		end

		-- Get the full text of the arrow function
		local bufnr = vim.api.nvim_get_current_buf()
		local text = vim.treesitter.get_node_text(node, bufnr)

		-- Find the body of the arrow function
		local body_node = nil
		for child in node:iter_children() do
			if child:type() == "statement_block" then
				-- Block body: { return value }
				body_node = child

				-- Extract the content between braces
				local body_text = vim.treesitter.get_node_text(child, bufnr)

				-- Try to extract return statement
				local return_value = body_text:match("^%s*{%s*return%s+(.-)%s*;?%s*}%s*$")

				if return_value then
					-- Has single return statement, convert to concise
					-- Get parameters
					local params = ""
					for param_child in node:iter_children() do
						if param_child:type() == "formal_parameters" or param_child:type() == "identifier" then
							params = vim.treesitter.get_node_text(param_child, bufnr)
							break
						end
					end

					return sn(nil, { i(1, params .. " => " .. return_value) })
				else
					return sn(nil, { i(1, "-- Complex block body, cannot convert") })
				end
			elseif child:type() ~= "formal_parameters" and child:type() ~= "identifier" and child:type() ~= "=>" then
				-- Concise body: expression
				body_node = child

				-- Get parameters
				local params = ""
				for param_child in node:iter_children() do
					if param_child:type() == "formal_parameters" or param_child:type() == "identifier" then
						params = vim.treesitter.get_node_text(param_child, bufnr)
						break
					end
				end

				-- Get body expression
				local body_text = vim.treesitter.get_node_text(child, bufnr)

				-- Convert to block body
				return sn(nil, { i(1, params .. " => { return " .. body_text .. " }") })
			end
		end

		return sn(nil, { i(1, "-- Could not parse arrow function") })
	end)
end

return {
	s("arrow", toggle_arrow_function()),
}
