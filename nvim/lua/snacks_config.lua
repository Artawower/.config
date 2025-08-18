local M = {}

function M.setup()
  local status_ok, snacks = pcall(require, "snacks")
  if not status_ok then
    return
  end

  -- Setup snacks with dashboard
  snacks.setup({
    dashboard = {
      enabled = true,
      preset = {
        name = "doom",
      },
    }
  })
  
  -- Set up keymap to open dashboard manually
  vim.keymap.set("n", "<leader>d", function() 
    snacks.dashboard.open() 
  end, { desc = "Open Dashboard" })
end

return M