-- markdown-essentials.lua
-- A LazyVim plugin for essential markdown editing operations

local M = {}

-- Helper function to apply text transformations
local function transform_text(mode, transformation)
  local save_cursor = vim.fn.getcurpos()
  
  if mode == "normal" then
    -- Get the current line
    local line = vim.fn.getline(".")
    -- Apply transformation
    local new_line = transformation(line)
    -- Replace the line
    vim.fn.setline(".", new_line)
  elseif mode == "visual" then
    -- Get visual selection
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local start_col = vim.fn.col("'<")
    local end_col = vim.fn.col("'>")
    
    -- Handle single line visual selection
    if start_line == end_line then
      local line = vim.fn.getline(start_line)
      local selected_text = string.sub(line, start_col, end_col)
      local transformed_text = transformation(selected_text)
      
      -- Replace the selected text
      local new_line = string.sub(line, 1, start_col - 1) .. transformed_text .. string.sub(line, end_col + 1)
      vim.fn.setline(start_line, new_line)
    else
      -- Handle multi-line visual selection
      for i = start_line, end_line do
        local line = vim.fn.getline(i)
        local transformed_line = transformation(line)
        vim.fn.setline(i, transformed_line)
      end
    end
  end
  
  vim.fn.setpos(".", save_cursor)
end

-- Toggle bold
function M.toggle_bold(mode)
  transform_text(mode, function(text)
    if string.match(text, "%*%*.*%*%*") then
      -- Remove bold
      return string.gsub(text, "%*%*(.-)%*%*", "%1")
    else
      -- Add bold
      return "**" .. text .. "**"
    end
  end)
end

-- Toggle italic
function M.toggle_italic(mode)
  transform_text(mode, function(text)
    if string.match(text, "%*.*%*") and not string.match(text, "%*%*.*%*%*") then
      -- Remove italic
      return string.gsub(text, "%*(.-)%*", "%1")
    else
      -- Add italic
      return "*" .. text .. "*"
    end
  end)
end

-- Convert a line to a todo item or remove todo status
function M.toggle_todo(mode)
  transform_text(mode, function(text)
    -- Check if it's already a todo item
    if string.match(text, "^%s*[-*] %[[ x]%]") then
      -- Remove todo status, keep bullet
      return string.gsub(text, "^(%s*[-*]) %[[ x]%]", "%1")
    elseif string.match(text, "^%s*[-*]%s") then
      -- It's a bullet point, convert to todo
      return string.gsub(text, "^(%s*[-*])%s", "%1 [ ] ")
    else
      -- It's not a bullet point, make it a todo
      return "- [ ] " .. text
    end
  end)
end

-- Toggle todo between incomplete and complete
function M.toggle_todo_done(mode)
  transform_text(mode, function(text)
    if string.match(text, "^%s*[-*] %[ %]") then
      -- Change to done
      return string.gsub(text, "^(%s*[-*]) %[ %]", "%1 [x]")
    elseif string.match(text, "^%s*[-*] %[x%]") then
      -- Change to not done
      return string.gsub(text, "^(%s*[-*]) %[x%]", "%1 [ ]")
    else
      -- Not a todo, leave unchanged
      return text
    end
  end)
end

-- Toggle bullet list
function M.toggle_bullet(mode)
  transform_text(mode, function(text)
    if string.match(text, "^%s*[-*]%s") then
      -- Remove bullet
      return string.gsub(text, "^(%s*)[-*]%s", "%1")
    else
      -- Add bullet
      return "- " .. text
    end
  end)
end

-- Toggle numbered list
function M.toggle_numbered(mode)
  transform_text(mode, function(text)
    if string.match(text, "^%s*%d+%.%s") then
      -- Remove numbering
      return string.gsub(text, "^(%s*)%d+%.%s", "%1")
    else
      -- Add numbering (always 1. for simplicity, user can manually adjust)
      return "1. " .. text
    end
  end)
end

-- Make text into header of specified level
function M.make_header(mode, level)
  level = level or 1
  local prefix = string.rep("#", level) .. " "
  
  transform_text(mode, function(text)
    -- Remove existing header if any
    text = string.gsub(text, "^%s*#+%s*", "")
    -- Add new header
    return prefix .. text
  end)
end

-- Make text normal (remove formatting)
function M.make_normal(mode)
  transform_text(mode, function(text)
    -- Remove header formatting
    text = string.gsub(text, "^%s*#+%s*", "")
    -- Remove bullet points
    text = string.gsub(text, "^%s*[-*]%s", "")
    -- Remove numbered list
    text = string.gsub(text, "^%s*%d+%.%s", "")
    -- Remove todo markers
    text = string.gsub(text, "^%s*[-*] %[[ x]%]%s*", "")
    -- Remove bold
    text = string.gsub(text, "%*%*(.-)%*%*", "%1")
    -- Remove italic
    text = string.gsub(text, "%*(.-)%*", "%1")
    
    return text
  end)
end

-- Setup function to be called by LazyVim
function M.setup(opts)
  opts = opts or {}
  
  -- Default keymappings
  local default_keymaps = {
    toggle_bold = "<leader>mb",
    toggle_italic = "<leader>mi",
    toggle_todo = "<leader>mt",
    toggle_todo_done = "<leader>md",
    toggle_bullet = "<leader>ml",
    toggle_numbered = "<leader>mn",
    make_header1 = "<leader>m1",
    make_header2 = "<leader>m2",
    make_header3 = "<leader>m3",
    make_normal = "<leader>m0",
  }
  
  local keymaps = vim.tbl_deep_extend("force", default_keymaps, opts.keymaps or {})
  
  -- Register normal mode keymaps
  vim.keymap.set("n", keymaps.toggle_bold, function() M.toggle_bold("normal") end, { desc = "Toggle bold" })
  vim.keymap.set("n", keymaps.toggle_italic, function() M.toggle_italic("normal") end, { desc = "Toggle italic" })
  vim.keymap.set("n", keymaps.toggle_todo, function() M.toggle_todo("normal") end, { desc = "Toggle todo" })
  vim.keymap.set("n", keymaps.toggle_todo_done, function() M.toggle_todo_done("normal") end, { desc = "Toggle todo done" })
  vim.keymap.set("n", keymaps.toggle_bullet, function() M.toggle_bullet("normal") end, { desc = "Toggle bullet list" })
  vim.keymap.set("n", keymaps.toggle_numbered, function() M.toggle_numbered("normal") end, { desc = "Toggle numbered list" })
  vim.keymap.set("n", keymaps.make_header1, function() M.make_header("normal", 1) end, { desc = "Make header 1" })
  vim.keymap.set("n", keymaps.make_header2, function() M.make_header("normal", 2) end, { desc = "Make header 2" })
  vim.keymap.set("n", keymaps.make_header3, function() M.make_header("normal", 3) end, { desc = "Make header 3" })
  vim.keymap.set("n", keymaps.make_normal, function() M.make_normal("normal") end, { desc = "Make normal text" })
  
  -- Register visual mode keymaps
  vim.keymap.set("v", keymaps.toggle_bold, function() M.toggle_bold("visual") end, { desc = "Toggle bold" })
  vim.keymap.set("v", keymaps.toggle_italic, function() M.toggle_italic("visual") end, { desc = "Toggle italic" })
  vim.keymap.set("v", keymaps.toggle_todo, function() M.toggle_todo("visual") end, { desc = "Toggle todo" })
  vim.keymap.set("v", keymaps.toggle_todo_done, function() M.toggle_todo_done("visual") end, { desc = "Toggle todo done" })
  vim.keymap.set("v", keymaps.toggle_bullet, function() M.toggle_bullet("visual") end, { desc = "Toggle bullet list" })
  vim.keymap.set("v", keymaps.toggle_numbered, function() M.toggle_numbered("visual") end, { desc = "Toggle numbered list" })
  vim.keymap.set("v", keymaps.make_header1, function() M.make_header("visual", 1) end, { desc = "Make header 1" })
  vim.keymap.set("v", keymaps.make_header2, function() M.make_header("visual", 2) end, { desc = "Make header 2" })
  vim.keymap.set("v", keymaps.make_header3, function() M.make_header("visual", 3) end, { desc = "Make header 3" })
  vim.keymap.set("v", keymaps.make_normal, function() M.make_normal("visual") end, { desc = "Make normal text" })
  
  -- Set up auto-commands if any
  if opts.auto_commands ~= false then
    vim.api.nvim_create_augroup("MarkdownEssentials", { clear = true })
    
    -- Auto-command examples (commented out by default)
    -- vim.api.nvim_create_autocmd("FileType", {
    --   group = "MarkdownEssentials",
    --   pattern = "markdown",
    --   callback = function()
    --     -- Add specific behavior for markdown files
    --   end,
    -- })
  end
end

return M