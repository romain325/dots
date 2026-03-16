-- vim.filetype.add({
--   pattern = {
--     ["hypr.+%.conf"] = "hyprlang",
--     [".*%.hl"] = "hyprlang",
--   },
-- })

return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    vim.list_extend(opts.servers, { "hyprlang" })

    -- opts.config = require("astrocore").extend_tbl(opts.config or {}, {
    --   hyprlang = {
    --     cmd = { "hyprls" },
    --     settings = {
    --       hyprls = {
    --         preferIgnoreFile = true,
    --         ignore = { "hyprlock.conf", "hypridle.conf" },
    --       },
    --     },
    --   }
    -- })
  end,
}
