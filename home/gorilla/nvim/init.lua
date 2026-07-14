-- A small, single-file Neovim 0.12 configuration.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Packages -------------------------------------------------------------------

vim.pack.add({
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/nvim-mini/mini.pick",
    "https://github.com/nvim-mini/mini.surround",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/tpope/vim-fugitive",
})

require("mini.surround").setup({})
require("mini.pick").setup({})

local which_key = require("which-key")
which_key.setup({
    delay = 300,
    filter = function(mapping)
        local lhs = (mapping.lhs or ""):upper()
        return lhs ~= "<C-D>" and lhs ~= "<C-U>"
    end,
    icons = { mappings = false },
    keys = {
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
    },
    preset = "helix",
    win = { border = "single" },
})

which_key.add({
    { "s", group = "Surround", mode = { "n", "x" } },
    { "<leader>?", desc = "Buffer keymaps" },
    { "<leader>c", group = "Code" },
    { "<leader>d", group = "Debug" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
})

vim.keymap.set("n", "<leader>?", function()
    which_key.show({ global = false })
end, { desc = "Buffer keymaps" })

local treesitter = require("nvim-treesitter")
local treesitter_languages = {
    "bash",
    "c",
    "cpp",
    "go",
    "gomod",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "nix",
    "python",
    "rust",
}

treesitter.setup({})
treesitter.install(treesitter_languages)

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup({
    actions = { open_file = { quit_on_open = false } },
    filters = { git_ignored = false },
    renderer = { group_empty = true },
    view = { width = 30 },
})

-- Appearance -----------------------------------------------------------------

vim.opt.termguicolors = true
vim.cmd.colorscheme("kanagawa")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "0"
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.pumheight = 10

-- Statusline -----------------------------------------------------------------

local mode_names = {
    ["n"] = "NORMAL",
    ["no"] = "OPERATOR",
    ["v"] = "VISUAL",
    ["V"] = "V-LINE",
    ["\22"] = "V-BLOCK",
    ["s"] = "SELECT",
    ["S"] = "S-LINE",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rv"] = "V-REPLACE",
    ["c"] = "COMMAND",
    ["t"] = "TERMINAL",
}

vim.api.nvim_set_hl(0, "StatuslineMode", { bg = "#7e9cd8", fg = "#16161d", bold = true })
vim.api.nvim_set_hl(0, "StatuslineGit", { bg = "#957fb8", fg = "#16161d", bold = true })
vim.api.nvim_set_hl(0, "StatuslineFile", { bg = "#1f1f28", fg = "#dcd7ba" })
vim.api.nvim_set_hl(0, "StatuslineError", { bg = "#1f1f28", fg = "#e82424", bold = true })
vim.api.nvim_set_hl(0, "StatuslineWarn", { bg = "#1f1f28", fg = "#e6c384", bold = true })
vim.api.nvim_set_hl(0, "StatuslineLsp", { bg = "#1f1f28", fg = "#7aa89f" })
vim.api.nvim_set_hl(0, "StatuslineMeta", { bg = "#16161d", fg = "#727169" })

function _G.statusline()
    local mode = mode_names[vim.fn.mode(1)] or vim.fn.mode(1):upper()
    local branch = ""
    if vim.fn.exists("*FugitiveHead") == 1 then
        local ok, head = pcall(vim.fn.FugitiveHead)
        if ok and head ~= "" then
            branch = "%#StatuslineGit#  " .. head .. " "
        end
    end

    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local diagnostics = ""
    if errors > 0 then
        diagnostics = diagnostics .. "%#StatuslineError# E:" .. errors .. " "
    end
    if warnings > 0 then
        diagnostics = diagnostics .. "%#StatuslineWarn# W:" .. warnings .. " "
    end

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local lsp = #clients > 0 and ("%#StatuslineLsp# " .. clients[1].name .. " ") or ""

    return table.concat({
        "%#StatuslineMode# ",
        mode,
        " ",
        branch,
        "%#StatuslineFile#  %f %m%r",
        "%=",
        diagnostics,
        lsp,
        "%#StatuslineMeta# %y  %l:%c  %p%% ",
    })
end

vim.opt.statusline = "%!v:lua.statusline()"

-- Editing --------------------------------------------------------------------

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
vim.opt.scrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.isfname:append("@-@")

-- Native completion shows LSP details in a documentation popup. Command-line
-- completion uses the same popup-menu style and fuzzy matching.
vim.opt.autocomplete = true
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
vim.opt.wildmode = { "noselect:lastused", "full" }
vim.opt.wildoptions = { "pum", "fuzzy" }

-- Autocommands ---------------------------------------------------------------

local general_group = vim.api.nvim_create_augroup("general", { clear = true })

vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#5c6370", fg = "#abb2bf" })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = general_group,
    callback = function()
        vim.hl.on_yank({ higroup = "YankHighlight", timeout = 200 })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = general_group,
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Language servers -----------------------------------------------------------

local servers = {
    clangd = {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
    },
    gopls = {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
    },
    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            },
        },
    },
    nixd = {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", ".git" },
        settings = { nixd = { formatting = { command = { "nixfmt" } } } },
    },
    pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    },
    rust_analyzer = {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" },
    },
}

for name, config in pairs(servers) do
    if vim.fn.executable(config.cmd[1]) == 1 then
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
    end
end

vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    virtual_text = { current_line = true },
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

        local function lsp_map(lhs, rhs, description)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = "LSP: " .. description })
        end

        lsp_map("gd", vim.lsp.buf.definition, "Go to definition")
        lsp_map("gD", vim.lsp.buf.declaration, "Go to declaration")
        lsp_map("gr", vim.lsp.buf.references, "References")
        lsp_map("K", vim.lsp.buf.hover, "Documentation")
        lsp_map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        lsp_map("<leader>rn", vim.lsp.buf.rename, "Rename")
    end,
})

vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { desc = "Open completion" })
vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, desc = "Next completion" })
vim.keymap.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "Previous completion" })

-- Picker and files -----------------------------------------------------------

local pick = require("mini.pick")
vim.keymap.set("n", "<leader><leader>", pick.builtin.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", pick.builtin.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", pick.builtin.grep_live, { desc = "Find text" })
vim.keymap.set("n", "<leader>fb", pick.builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", pick.builtin.help, { desc = "Find help" })
vim.keymap.set("n", "<leader>fr", pick.builtin.resume, { desc = "Resume picker" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file in tree" })

-- Debugger -------------------------------------------------------------------

local dap = require("dap")

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" },
}

dap.configurations.c = {
    {
        name = "Launch executable",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}
dap.configurations.cpp = dap.configurations.c

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/continue" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step into" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Debug: Step over" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Stop" })

-- Git ------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Git log" })

-- General keymaps ------------------------------------------------------------

vim.keymap.set("x", "p", [['_dP]], { desc = "Paste without replacing the register" })
vim.keymap.set({ "n", "x" }, "<leader>D", [['_d]], { desc = "Delete without yanking" })
vim.keymap.set({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set({ "n", "x" }, "C", '"_C', { desc = "Change line without yanking" })

vim.keymap.set({ "n", "x" }, "G", "G$zz")
vim.keymap.set({ "n", "x" }, "gg", "gg^zz")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

vim.keymap.set({ "n", "x" }, "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set({ "n", "x" }, "<leader>QQ", "<cmd>q!<CR>", { desc = "Force quit" })

vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("x", "<", "<gv", { desc = "Unindent selection" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent selection" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
    desc = "Replace word in buffer",
})

vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle undo tree" })

local function save_and_format()
    local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" })
    if #clients > 0 then
        vim.lsp.buf.format({ async = false })
    end
    vim.cmd.update()
end

vim.keymap.set({ "i", "n", "x" }, "<C-s>", save_and_format, { desc = "Format and save" })
