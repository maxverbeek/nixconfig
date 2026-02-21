vim.api.nvim_create_user_command("GitPushReviewer", function()
  local output = vim.fn.system("gitlab-reviewer")

  if vim.v.shell_error ~= 0 then
    vim.notify("gitlab-reviewer failed: " .. output, vim.log.levels.ERROR)
    return
  end

  -- Parse TSV output into list of {name, username}
  local members = {}
  for line in output:gmatch("[^\r\n]+") do
    local name, username = line:match("^(.-)\t(.*)$")
    if name then
      table.insert(members, { name = name, username = username })
    end
  end

  if #members == 0 then
    vim.notify("No reviewers found", vim.log.levels.WARN)
    return
  end

  -- Build display list for vim.ui.select
  local display = {}
  for _, m in ipairs(members) do
    if m.username ~= "" then
      table.insert(display, m.name .. " (@" .. m.username .. ")")
    else
      table.insert(display, m.name .. " (no username)")
    end
  end

  -- Show selector (dressing.nvim enhances this)
  vim.ui.select(display, { prompt = "Select reviewer:" }, function(choice, idx)
    if not choice or not idx then
      return
    end

    local selected = members[idx]

    if selected.username == "" then
      -- Fallback: prompt for username manually
      vim.ui.input({ prompt = "GitLab username for " .. selected.name .. ": " }, function(input)
        if input and input ~= "" then
          vim.cmd("Git mpr " .. input)
        end
      end)
    else
      vim.cmd("Git mpr " .. selected.username)
    end
  end)
end, { desc = "Push and create MR with reviewer" })
