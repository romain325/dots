-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  {
    "b0o/schemastore.nvim",
  },
  ---@type LazySpec
  {
    "AstroNvim/astrolsp",
    dependencies = {
      "b0o/schemastore.nvim",
    },
    ---@type AstroLSPOpts
    opts = {

      features = {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      formatting = {
        format_on_save = {
          enabled = true,
        },
        disabled = { -- disable formatting capabilities for the listed language servers
          "volar",
        },
        timeout_ms = 10000, -- default format timeout
        -- filter = function(client) -- fully override the default formatting function
        --   return true
        -- end
      },

      -- enable servers that you already have installed without mason
      servers = {
        -- "pyright"
      },
      -- customize language server configuration options passed to `lspconfig`
      ---@diagnostic disable: missing-fields
      config = {
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
      -- customize how language servers are attached
      handlers = {
        -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
        -- function(server, opts) require("lspconfig")[server].setup(opts) end

        -- the key is the server that is being setup with `lspconfig`
        -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
        -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
      },
      -- Configure buffer local auto commands to add when attaching a language server
      autocmds = {
        -- first key is the `augroup` to add the auto commands to (:h augroup)
        lsp_codelens_refresh = {
          -- Optional condition to create/delete auto command group
          -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
          -- condition will be resolved for each client on each execution and if it ever fails for all clients,
          -- the auto commands will be deleted for that buffer
          cond = "textDocument/codeLens",
          -- cond = function(client, bufnr) return client.name == "lua_ls" end,
          -- list of auto commands to set
          {
            -- events to trigger
            event = { "InsertLeave", "BufEnter" },
            -- the rest of the autocmd options (:h nvim_create_autocmd)
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
            end,
          },
        },
      },
      -- mappings to be set up on attaching of a language server
      mappings = {
        n = {
          -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
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
      -- A custom `on_attach` function to be run after the default `on_attach` function
      -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
      on_attach = function(client, bufnr)
        -- this would disable semanticTokensProvider for all clients
        -- client.server_capabilities.semanticTokensProvider = nil
      end,
    },
  },
}
