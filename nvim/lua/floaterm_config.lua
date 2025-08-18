local M = {}

function M.setup()
  local floaterm = require("floaterm")
  
  floaterm.setup({
    border = true,
    size = { h = 60, w = 70 },
    position = "right", -- Open terminal in a split on the right side
    terminals = {
      { name = "Terminal" },
      { name = "Terminal", cmd = "neofetch" },
    },
  })
  
  -- Prefer calling toggle if plugin exposes it; otherwise emulate
  local function do_toggle()
    if type(floaterm.toggle) == "function" then
      pcall(floaterm.toggle)
      return
    end
    local closed_ok = pcall(floaterm.close)
    if not closed_ok then
      pcall(floaterm.open)
    end
  end
  
  -- Set up keymap to toggle floaterm (normal and terminal modes), no <C-\\> usage
  vim.keymap.set({"n", "t"}, "<F6>", function()
    if vim.fn.mode() == 't' then
      -- Programmatically leave terminal-mode without relying on user keybinds
      local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
      vim.api.nvim_feedkeys(esc, "n", false)
      vim.schedule(do_toggle)
    else
      do_toggle()
    end
  end, { desc = "Toggle Floaterm", silent = true })
  
  -- Alternative keymaps for explicit open/close
  vim.keymap.set("n", "<leader>fo", function() pcall(floaterm.open) end, { desc = "Open Floaterm" })
  
  vim.keymap.set("n", "<leader>fc", function() pcall(floaterm.close) end, { desc = "Close Floaterm" })

  -- Keymap to switch to the floaterm window (right side)
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Switch to Floaterm Window" })
end

return M
