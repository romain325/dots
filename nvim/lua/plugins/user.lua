---@type LazySpec
return {
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
 "█             ▀▀█    █             █                   ",
 "█   ▄   ▄▄▄     █    █   ▄   ▄▄▄   █ ▄▄    ▄▄▄   ▄▄▄▄▄ ",
 "█ ▄▀   █▀  █    █    █ ▄▀   █▀  ▀  █▀  █  █▀ ▀█     ▄▀ ",
 "█▀█    █▀▀▀▀    █    █▀█    █      █   █  █   █   ▄▀   ",
 "█  ▀▄  ▀█▄▄▀    ▀▄▄  █  ▀▄  ▀█▄▄▀  █   █  ▀█▄█▀  █▄▄▄▄ "
      }
      return opts
    end,
  },

}
