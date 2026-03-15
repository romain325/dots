return {
  {
    "b0o/schemastore.nvim",
  },
  {
    "AstroNvim/astrolsp",
    dependencies = {
      {"b0o/schemastore.nvim"},
    },
    
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      opts.features = require("astrocore").extend_tbl(opts.feature or {}, {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      })
      opts.formatting = require("astrocore").extend_tbl(opts.formatting or {}, {
        format_on_save = {
          enabled = true,
        },
        disabled = {
          "volar",
        },
        timeout_ms = 10000, 
      })

      ---@diagnostic disable: missing-fields
      opts.config = {
        ts_ls = {
          on_new_config = function(new_config, new_root_dir)
            -- Get the vue-language-server path from Mason
            local mason_registry = require "mason-registry"
            if mason_registry.is_installed "vue-language-server" then
              local vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path()
                .. "/node_modules/@vue/language-server"

              new_config.init_options = new_config.init_options or {}
              new_config.init_options.plugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_language_server_path,
                  languages = { "vue" },
                },
              }
            end
          end,
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        },

        -- Volar for Vue template features
        volar = {
          init_options = {
            vue = {
              hybridMode = true, -- Let ts_ls handle TypeScript
            },
          },
        },

        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://json.schemastore.org/openapi-3.X.json"] = "**/*.api.yaml",
              },
            },
          },
        },
      },
      opts.autocmds = {
        lsp_codelens_refresh = {
          cond = "textDocument/codeLens",
          {
            event = { "InsertLeave", "BufEnter" },
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
            end,
          },
        },
      },
      opts.mappings = {
        n = {
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
          ["<Leader>uY"] = {
            function() require("astrolsp.toggles").buffer_semantic_tokens() end,
            desc = "Toggle LSP semantic highlight (buffer)",
            cond = function(client)
              return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
            end,
          },
        },
      },
    end,
  },
}
