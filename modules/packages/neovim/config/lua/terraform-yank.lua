local M = {}

--- Walk up the tree from the cursor to find the enclosing HCL block,
--- then return its Terraform address (e.g. "module.foo", "resource.type.name").
function M.get_address()
  local node = vim.treesitter.get_node()
  if not node then
    return nil
  end

  -- Walk up to the nearest `block` node
  while node and node:type() ~= "block" do
    node = node:parent()
  end
  if not node then
    return nil
  end

  -- Collect the identifier and string_lit children (in order)
  local parts = {}
  for child in node:iter_children() do
    if child:type() == "identifier" then
      table.insert(parts, vim.treesitter.get_node_text(child, 0))
    elseif child:type() == "string_lit" then
      -- The actual text lives in the template_literal inside the string_lit
      for inner in child:iter_children() do
        if inner:type() == "template_literal" then
          table.insert(parts, vim.treesitter.get_node_text(inner, 0))
        end
      end
    end
  end

  if #parts == 0 then
    return nil
  end

  return table.concat(parts, ".")
end

return M
