-- A small, single-file Neovim 0.12 configuration.
vim.g.maplocalleader = " "
vim.g.mapleader = " "

-- Packages -------------------------------------------------------------------

vim.pack.add({
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/mfussenegger/nvim-dap",
})

local mini_icons = require("mini.icons")
mini_icons.setup({})
mini_icons.tweak_lsp_kind()

require("mini.notify").setup({
    lsp_progress = { enable = false },
})
require("mini.cmdline").setup({ autocomplete = { delay = 100 } })
local mini_completion = require("mini.completion")
mini_completion.setup({
    lsp_completion = { source_func = "omnifunc", auto_setup = false },
})
require("mini.surround").setup({})
require("mini.move").setup({
    mappings = {
        left = "<A-h>",
        right = "<A-l>",
        down = "<A-j>",
        up = "<A-k>",
        line_left = "<A-h>",
        line_right = "<A-l>",
        line_down = "<A-j>",
        line_up = "<A-k>",
    },
})
require("mini.pick").setup({})
vim.ui.select = MiniPick.ui_select
require("mini.files").setup({})
require("mini.tabline").setup({ show_icons = true })
require("mini.bufremove").setup({})
require("mini.diff").setup({
    view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "" },
    },
})
require("mini.git").setup({})
require("mini.indentscope").setup({
    draw = { animation = require("mini.indentscope").gen_animation.none() },
})
require("mini.sessions").setup({ file = ".session.vim" })

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
    -- "<auto>" keeps the default detection; "s" must be explicit because
    -- which-key does not auto-trigger on keys that shadow built-ins.
    triggers = {
        { "<auto>", mode = "nixsotc" },
        { "s", mode = { "n", "x" } },
    },
    win = { border = "single" },
})

which_key.add({
    { "s", group = "Surround", mode = { "n", "x" } },
    { "<leader>?", desc = "Buffer keymaps" },
    { "<leader>b", group = "Buffers" },
    { "<leader>c", group = "Code" },
    { "<leader>d", group = "Debug" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>n", group = "Notifications" },
    { "<leader>s", group = "Sessions" },
    { "<leader>w", group = "Windows" },
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
    "zig",
}

treesitter.setup({})
treesitter.install(treesitter_languages)

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
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
vim.api.nvim_set_hl(0, "StatuslineDiff", { bg = "#1f1f28", fg = "#7aa89f" })

function _G.statusline()
    local mode = mode_names[vim.fn.mode(1)] or vim.fn.mode(1):upper()
    local git_summary = vim.b.minigit_summary_string
    local branch = git_summary and git_summary ~= "" and ("%#StatuslineGit#  " .. git_summary .. " ") or ""

    local diff = ""
    local diff_summary = vim.b.minidiff_summary_string
    if diff_summary and diff_summary ~= "" then
        diff = "%#StatuslineDiff# " .. diff_summary .. " "
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
        diff,
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
vim.opt.autocomplete = false
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

vim.api.nvim_create_autocmd("FileType", {
    group = general_group,
    pattern = { "help", "minifiles", "minipick", "notify" },
    callback = function()
        vim.b.miniindentscope_disable = true
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
    zls = {
        cmd = { "zls" },
        filetypes = { "zig" },
        root_markers = { "build.zig", "build.zig.zon", ".git" },
    },
}

for name, config in pairs(servers) do
    if vim.fn.executable(config.cmd[1]) == 1 then
        config.capabilities = vim.tbl_deep_extend(
            "force",
            config.capabilities or {},
            mini_completion.get_lsp_capabilities()
        )
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
        vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

        local function lsp_map(lhs, rhs, description)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = "LSP: " .. description })
        end

        lsp_map("gd", vim.lsp.buf.definition, "Go to definition")
        lsp_map("gD", vim.lsp.buf.declaration, "Go to declaration")
        lsp_map("gr", vim.lsp.buf.references, "References")
        lsp_map("<leader>k", vim.lsp.buf.hover, "Documentation")
        lsp_map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        lsp_map("<leader>rn", vim.lsp.buf.rename, "Rename")
    end,
})

local function completion_or_snippet(direction)
    if vim.fn.pumvisible() == 1 then
        return direction == 1 and "<C-n>" or "<C-p>"
    end
    if vim.snippet.active({ direction = direction }) then
        return ("<Cmd>lua vim.snippet.jump(%d)<CR>"):format(direction)
    end
    return direction == 1 and "<Tab>" or "<S-Tab>"
end

vim.keymap.set({ "i", "s" }, "<Tab>", function()
    return completion_or_snippet(1)
end, { expr = true, silent = true, desc = "Next completion or snippet placeholder" })
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    return completion_or_snippet(-1)
end, { expr = true, silent = true, desc = "Previous completion or snippet placeholder" })

-- Picker and files -----------------------------------------------------------

local pick = require("mini.pick")
vim.keymap.set("n", "<leader><leader>", pick.builtin.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", pick.builtin.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", pick.builtin.grep_live, { desc = "Find text" })
vim.keymap.set("n", "<leader>fb", pick.builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", pick.builtin.help, { desc = "Find help" })
vim.keymap.set("n", "<leader>fr", pick.builtin.resume, { desc = "Resume picker" })
vim.keymap.set("n", "<leader>e", function()
    if not MiniFiles.close() then
        MiniFiles.open(vim.uv.cwd(), true)
    end
end, { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>E", function()
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Reveal file in explorer" })

vim.keymap.set("n", "<leader>nh", MiniNotify.show_history, { desc = "Notification history" })
vim.keymap.set("n", "<leader>nc", MiniNotify.clear, { desc = "Clear notifications" })

vim.keymap.set("n", "<leader>ss", function()
    MiniSessions.select("read")
end, { desc = "Select session" })
vim.keymap.set("n", "<leader>sc", function()
    vim.ui.input({ prompt = "Session name: " }, function(name)
        if name and name ~= "" then
            MiniSessions.write(name)
        end
    end)
end, { desc = "Create named session" })
vim.keymap.set("n", "<leader>sw", function()
    MiniSessions.write()
end, { desc = "Write active session" })
vim.keymap.set("n", "<leader>sl", function()
    MiniSessions.write(".session.vim")
end, { desc = "Create local session" })
vim.keymap.set("n", "<leader>sd", function()
    MiniSessions.select("delete")
end, { desc = "Delete session" })

-- Windows --------------------------------------------------------------------

vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Go to next window" })
vim.keymap.set("n", "<leader>ws", "<cmd>split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close window" })
vim.keymap.set("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })

-- Buffers ----------------------------------------------------------------------

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

vim.keymap.set("n", "<leader>bd", function()
    require("mini.bufremove").delete(0, false)
end, { desc = "Delete buffer" })

vim.keymap.set("n", "<leader>bo", function()
    local current = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.bo[buf].buflisted then
            require("mini.bufremove").delete(buf, false)
        end
    end
end, { desc = "Delete other buffers" })

vim.keymap.set("n", "<leader>bx", function()
    local buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
            if vim.bo[buf].modified then
                vim.notify("Cannot delete all buffers: unsaved changes", vim.log.levels.WARN)
                return
            end
            table.insert(buffers, buf)
        end
    end
    for _, buf in ipairs(buffers) do
        require("mini.bufremove").delete(buf, false)
    end
end, { desc = "Delete all buffers" })

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
dap.configurations.zig = dap.configurations.c

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/continue" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step into" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Debug: Step over" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Stop" })

-- Git ------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gs", "<cmd>Git status<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", "<cmd>vertical Git blame -- %<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gd", "<cmd>Git diff<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Git log" })
vim.keymap.set({ "n", "x" }, "<leader>gh", MiniGit.show_at_cursor, { desc = "Git history at cursor" })
vim.keymap.set("n", "<leader>go", function()
    require("mini.diff").toggle_overlay(0)
end, { desc = "Toggle git diff overlay" })

-- General keymaps ------------------------------------------------------------

vim.keymap.set("x", "p", [['_dP]], { desc = "Paste without replacing the register" })
vim.keymap.set({ "n", "x" }, "<leader>d", "d", { desc = "Delete without yanking" })
vim.keymap.set({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set({ "n", "x" }, "C", '"_C', { desc = "Change line without yanking" })

vim.keymap.set({ "n", "x" }, "G", "G$zz")
vim.keymap.set({ "n", "x" }, "gg", "gg^zz")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("x", "<", "<gv", { desc = "Unindent selection" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent selection" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

vim.keymap.set("x", "<leader>r", "\"hy:%s/<C-r>h//g<left><left>", {
    desc = "Replace word under selection",
})

vim.keymap.set("i", "<C-s>", "<cmd>w<CR><ESC>")
vim.keymap.set({ "n", "x" }, "<C-s>", "<cmd>w<CR>")
