-- Open file in nvim with O key
function setup(config)
  config.action("open in nvim", function()
    local file = context.file()
    if not file then
      flash("Select file first (press l for details)")
      return
    end
    exec_shell("hx " .. file)
  end, {
    key = "O",
    scope = "revisions.details",
    desc = "open in nvim",
  })
end
