-- Загрузка Packer
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'nvim-treesitter/nvim-treesitter'
    use 'nvim-lua/plenary.nvim'
    
    -- ДОБАВЛЕНО: Файловое дерево и иконки
    use 'nvim-tree/nvim-tree.lua'
    use 'nvim-tree/nvim-web-devicons'
end)

-- Базовые настройки NeoVim
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true

-- ДОБАВЛЕНО: Отключение стандартного файлового менеджера (важно для nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Убрать тильды на пустых строках
vim.opt.fillchars = { eob = ' ' }

-- Прозрачность
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NonText', { bg = 'none' })
vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Folded', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })

-- ДОБАВЛЕНО: Настройка файлового дерева nvim-tree
require("nvim-tree").setup({
    view = {
        width = 35,
        side = "right", -- панель справа как в VSCode
    },
    renderer = {
        group_empty = true,
        icons = {
            glyphs = {
                folder = {
                    arrow_closed = "▶",
                    arrow_open = "▼",
                },
            },
        },
    },
    filters = {
        dotfiles = false, -- показывать скрытые файлы
    },
    actions = {
        open_file = {
            quit_on_open = true, -- закрыть дерево после открытия файла
        },
    },
})

-- ДОБАВЛЕНО: Горячая клавиша для дерева файлов
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })

-- Mason настройка
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {}, -- оставляем пустым
    automatic_installation = false,
})

-- Настройка LSP (новый API для NeoVim 0.11.4)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Глобальные LSP ключи
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format code' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })

-- Автозапуск LSP серверов при открытии файлов
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'python', 'cpp', 'c', 'go'},
    callback = function(args)
        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype
        
        local config = {
            capabilities = capabilities
        }
        
        if filetype == 'python' then
            config.cmd = { 'pylsp' }
            config.settings = {
                pylsp = {
                    plugins = {
                        pyflakes = {enabled = false},
                        autopep8 = {enabled = false},
                        mccabe = {enabled = false},
                        pycodestyle = {enabled = false},
                        pydocstyle = {enabled = false},
                        pylint = {enabled = false},
                        rope = {enabled = false},
                        yapf = {enabled = false},
                        flake8 = {enabled = false},
                        mypy = {enabled = false},
                        pyls_isort = {enabled = false},
                        pyls_black = {enabled = false},
                        pyls_mypy = {enabled = false},
                        pyls_rope = {enabled = false},

                        jedi_completion = {enabled = true},
                        jedi_definition = {enabled = true},
                        jedi_hover = {enabled = true},
                        jedi_references = {enabled = true},
                        jedi_signature_help = {enabled = true},
                        jedi_symbols = {enabled = true},
                    }
                }
            }
        elseif filetype == 'cpp' or filetype == 'c' then
            config.cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy", 
                "--header-insertion=never",
            }
        elseif filetype == 'go' then
            config.cmd = { 'gopls' }
            config.settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                },
            }
        end
        
        vim.lsp.start(config)
    end,
})

-- Autocompletion настройка
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
})

-- Treesitter настройка
require('nvim-treesitter.configs').setup({
    ensure_installed = { 'python', 'c', 'cpp', 'lua', 'bash', 'go', 'vim', 'json' },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
})

-- Диагностика
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Значки диагностики
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Автоформатирование при сохранении
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = {'*.py', '*.cpp', '*.go', '*.lua'},
    callback = function() 
        if vim.lsp.get_active_clients() then
            vim.lsp.buf.format() 
        end
    end
})

print("✅ NeoVim 0.11.4 config loaded! Use :MasonInstall clangd gopls")
