return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    vim.list_extend(opts.servers, {"nixd"})

    opts.config = opts.config or {}
    opts.config.nixd = {
      settings = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> { }"
          },
          formattings = {
            command = {"nixfmt"},
          }
        }
      }
    }
  end,
}
