return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    vim.list_extend(opts.servers, {"hyprlang"})

    opts.config = opts.config or {}
    opts.config.hyprlang = {
      cmd = { "hyprls" },
      settings = {
        preferIgnoreFile = true,
        ignore = { "hyprlock.conf" }
      } 
    }
  end,
}
