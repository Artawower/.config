local M = {}

function M.setup()
  local menu = require("menu")
  
  -- Define default menu
  menu.menus = {
    default = {
      { "Files", "Telescope find_files" },
      { "Recent", "Telescope oldfiles" },
      { "Projects", "Telescope projects" },
      { "Grep", "Telescope live_grep" },
      { "--", "--" },
      { "NvimTree", "NvimTreeToggle" },
      { "Buffers", "Telescope buffers" },
      { "Marks", "Telescope marks" },
      { "--", "--" },
      { "Settings", "e ~/.config/nvim/lua/plugins.lua" },
      { "Plugins", "Lazy" },
      { "Help", "Telescope help_tags" },
    },
    nvimtree = {
      { "Reveal", "NvimTreeFindFile" },
      { "Refresh", "NvimTreeRefresh" },
      { "--", "--" },
      { "Collapse", "NvimTreeCollapse" },
      { "Toggle", "NvimTreeToggle" },
    },
  }
  
  -- Set up keymap to open the menu
  vim.keymap.set("n", "<C-t>", function()
    menu.open("default")
  end, { desc = "Open Menu" })
  
  -- Set up right-click context menu
  vim.keymap.set({"n", "v"}, "<RightMouse>", function()
    require('menu.utils').delete_old_menus()
    vim.cmd('exec "normal! \\<RightMouse>"')
    local buf = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
    local options = vim.bo[buf].ft == "NvimTree" and "nvimtree" or "default"
    menu.open(options, { mouse = true })
  end, { desc = "Context Menu" })
end

return M