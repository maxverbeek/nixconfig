local ls = require("luasnip")

-- Get a list of  the property names given an `interface_declaration`
-- treesitter *tsx* node.
-- Ie, if the treesitter node represents:
--   interface {
--     prop1: string;
--     prop2: number;
--   }
-- Then this function would return `{"prop1", "prop2"}
---@param id_node {} Stands for "interface declaration node"
---@return string[]
local function get_prop_names(id_node)
	local type_alias_node = id_node:child(1)

	if type_alias_node:type() ~= "type_alias_declaration" then
		return {}
	end

	object_type_node = type_alias_node:child(3)

	if object_type_node:type() ~= "object_type" then
		return {}
	end

	local prop_names = {}

	for prop_signature in object_type_node:iter_children() do
		if prop_signature:type() == "property_signature" then
			for prop_id in prop_signature:iter_children() do
				if prop_id:type() == "property_identifier" then
					local prop_name = vim.treesitter.query.get_node_text(prop_id, 0)
					prop_names[#prop_names + 1] = prop_name
				end
			end
		end
	end

	return prop_names
end

local function suggest_filename(fname, dname)
	print("fname", vim.inspect(fname))
	print("dname", vim.inspect(dname))
	if fname == "index" then
		return vim.fn.substitute(dname, "^.*/", "", "g")
	else
		return fname
	end
end

return {
	s(
		"newcomp",
		fmt(
			[[
export type {}Props = {{
  {}
}}

const {} = ({{ {} }}: {}Props) => {{
  {}
}}

export default {}
]],
			{
				-- Initialize component name to file name
				d(1, function(_, snip)
					return sn(1, {
						i(1, suggest_filename(snip.env.TM_FILENAME_BASE, snip.env.TM_DIRECTORY)),
					})
				end, {}),
				i(2, "// props"),
				rep(1),
				f(function(_, snip, _)
					local pos_begin = snip.nodes[1].mark:pos_begin()
					local pos_end = snip.nodes[1].mark:pos_end()
					local parser = vim.treesitter.get_parser(0, "tsx")
					local tstree = parser:parse()

					local node =
						tstree[1]:root():named_descendant_for_range(pos_begin[1], pos_begin[2], pos_end[1], pos_end[2])

					while node ~= nil and node:type() ~= "export_statement" do
						node = node:parent()
					end

					if node == nil then
						return ""
					end

					-- `node` is now surely of type "interface_declaration"
					local prop_names = get_prop_names(node)

					-- Does this lua->vimscript->lua thing cause a slow down? Dunno.
					return vim.fn.join(prop_names, ", ")
				end, { 2 }),
				rep(1),
				i(3, "return <div></div>"),
				rep(1),
			}
		)
	),
}
