local lspconfig = require('lspconfig')

lspconfig.millet.setup {
    cmd = { "millet-ls" },
    filetypes = { "sml" },
    -- Use current working directory when no project file is detected
    root_dir = function(fname)
        return lspconfig.util.root_pattern(".millet.toml", ".git")(fname) or vim.loop.cwd()
    end,
    on_attach = function(client, bufnr)
        print("Millet attached to buffer " .. bufnr)
    end,
}

