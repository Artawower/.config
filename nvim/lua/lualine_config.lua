local uv = require("luv")

local currentTime = ""
local function set_interval(interval, callback)
    local timer = uv.new_timer()
    local function ontimeout()
        callback(timer)
    end
    uv.timer_start(timer, interval, interval, ontimeout)
    return timer
end

local function update_wakatime()
    local stdin = uv.new_pipe()
    local stdout = uv.new_pipe()
    local stderr = uv.new_pipe()

    local handle, pid =
        uv.spawn(
        "wakatime",
        {
            args = {"--today"},
            stdio = {stdin, stdout, stderr}
        },
        function(code, signal) -- on exit
            stdin:close()
            stdout:close()
            stderr:close()
        end
    )

    uv.read_start(
        stdout,
        function(err, data)
            assert(not err, err)
            if data then
                -- print("stdout chunk", data)
                currentTime = "🅆 " .. data:sub(1, #data - 2) .. " "
            end
        end
    )
end

set_interval(5000, update_wakatime)

local function get_wakatime()
    return currentTime
end

require("lualine").setup {
    options = {
--        theme = "nightfly"
        -- component_separators = "|",
        -- section_separators = {left = "", right = ""}
        -- component_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = '' }
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'packer', 'NvimTree' }
    },
    sections = {
        lualine_a = {
            {"mode", separator = {left = ""}, right_padding = 2}
        },
        lualine_b = {"filename", "branch"},
        lualine_c = {"fileformat"},
        lualine_x = {},
        lualine_y = {"filetype", "progress", get_wakatime},
        lualine_z = {
            {"location", separator = {right = ""}, left_padding = 2}
        }
    },
    inactive_sections = {
        lualine_a = {"filename"},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {"location"}
    },
    tabline = {},
    extensions = { }
  }

vim.opt.list = true;
