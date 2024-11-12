-- File: lua/c.lua --

require('lspconfig').clangd.setup({
    on_attach = function(_, bufnr)
        local opts = { noremap=true, silent=true }
        -- Keymaps for LSP actions in C/C++ files
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>r', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<Cmd>lua vim.lsp.buf.format()<CR>', opts)

        -- Enable diagnostics and formatting on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ async = true })  -- Auto-format on save
                vim.lsp.buf.code_action({  -- Run code actions, such as clang-tidy fixes
                    context = { only = { "source.fixAll" } },
                    apply = true,
                })
            end,
        })
    end,
    settings = {
        clangd = {
            fallbackFlags = {"-std=c11"}  -- Set standard to C11 (adjust if needed)
        }
    }
})

