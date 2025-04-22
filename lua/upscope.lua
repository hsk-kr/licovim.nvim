-- Upscope test runner with toggleable sidebar output window
-- Works with Neovim ≥ 0.11

local M = {}

---------------------------------------------------------------------
-- Helpers -----------------------------------------------------------
---------------------------------------------------------------------

---Return path of current file relative to CWD (empty string if none)
---@return string
local function get_current_file_relative_path()
  local current_file = vim.fn.expand("%:p")
  return vim.fn.fnamemodify(current_file, ":.")
end

---Calculate sidebar width (30 % of the editor, minimum 20 cols)
---@return integer
local function sidebar_width()
  return math.max(math.floor(vim.o.columns * 0.30), 20)
end

---Check if a job is still running
---@return boolean
local function job_is_running()
  if not M.job_id then return false end
  -- jobwait returns -1 if still running, exit‑code otherwise
  local status = vim.fn.jobwait({ M.job_id }, 0)[1]
  return status == -1
end

---------------------------------------------------------------------
-- Window management -------------------------------------------------
---------------------------------------------------------------------

---Open (or get) the sidebar window
---@return integer buf handle, integer win handle
function M.open_sidebar()
  -- Re‑use valid buffer/window if available
  if M.output_buf and vim.api.nvim_buf_is_valid(M.output_buf)
      and M.output_win and vim.api.nvim_win_is_valid(M.output_win) then
    return M.output_buf, M.output_win
  end

  -- Ensure we have a scratch buffer (hide = "wipe" to keep after close)
  if not (M.output_buf and vim.api.nvim_buf_is_valid(M.output_buf)) then
    M.output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[M.output_buf].bufhidden = "hide"
    vim.bo[M.output_buf].filetype  = "upscope-log"
  end

  -- Floating sidebar on the RHS
  local width  = sidebar_width()
  local height = vim.o.lines - 2 -- leave a line for cmd‑line
  local col    = vim.o.columns - width
  local row    = 0

  M.output_win = vim.api.nvim_open_win(M.output_buf, true, {
    relative = "editor",
    width    = width,
    height   = height,
    col      = col,
    row      = row,
    style    = "minimal",
    border   = "single",
  })

  -- Basic options for readability
  vim.wo[M.output_win].wrap = false
  vim.wo[M.output_win].cursorline = true

  return M.output_buf, M.output_win
end

---Close the sidebar window (buffer remains, job keeps running)
function M.close_sidebar()
  if M.output_win and vim.api.nvim_win_is_valid(M.output_win) then
    vim.api.nvim_win_close(M.output_win, true)
  end
  M.output_win = nil
end

---Toggle the sidebar window visibility
function M.toggle_sidebar()
  if M.output_win and vim.api.nvim_win_is_valid(M.output_win) then
    M.close_sidebar()
  else
    M.open_sidebar()
  end
end

---Clear the sidebar output log without affecting any running job
function M.clear_output()
  if not (M.output_buf and vim.api.nvim_buf_is_valid(M.output_buf)) then
    vim.notify("No output to clear.", vim.log.levels.INFO, { title = "Upscope" })
    return
  end
  vim.api.nvim_buf_set_lines(M.output_buf, 0, -1, false, {})
end

---------------------------------------------------------------------
-- Upscope test runner ----------------------------------------------
---------------------------------------------------------------------

---Run (or re‑focus) upscope tests for the current file
function M.upscope_test_current_file()
  local relative_path = get_current_file_relative_path()
  if relative_path == "" then
    vim.notify("No file detected.", vim.log.levels.WARN)
    return
  end

  -- Always show the sidebar; don’t start a new job if one is active
  local output_buf = M.open_sidebar()

  if job_is_running() then
    vim.notify("Upscope test already running – showing output only.", vim.log.levels.INFO, { title = "Upscope" })
    return
  end

  -- Clear previous content
  vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, {})

  -------------------------------------------------------------------
  -- Start async job -------------------------------------------------
  -------------------------------------------------------------------

  local command = { "upscope", "test", "api", "-t", relative_path }

  M.job_id = vim.fn.jobstart(command, {
    stdout_buffered = false,

    on_stdout = function(_, data)
      if not data then return end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
        -- Auto‑scroll to bottom when sidebar is visible
        if M.output_win and vim.api.nvim_win_is_valid(M.output_win) then
          vim.api.nvim_win_set_cursor(M.output_win, { vim.api.nvim_buf_line_count(output_buf), 0 })
        end
      end)
    end,

    on_stderr = function(_, data)
      if not data then return end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
      end)
    end,

    on_exit = function(_, code)
      vim.schedule(function()
        local msg = (code == 0) and "Process finished successfully."
                    or ("Process exited with code " .. code .. ".")
        vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { "", msg })
        M.job_id = nil
      end)
    end,
  })

  if M.job_id <= 0 then
    vim.notify("Failed to start upscope test (executable not found?)", vim.log.levels.ERROR, { title = "Upscope" })
    M.job_id = nil
  end
end

---------------------------------------------------------------------
-- User‑friendly commands & keymaps (optional) -----------------------
---------------------------------------------------------------------

-- Example commands (uncomment to enable)
-- vim.api.nvim_create_user_command("UpscopeTest",   M.upscope_test_current_file, {})
-- vim.api.nvim_create_user_command("UpscopeToggle", M.toggle_sidebar,           {})
-- vim.api.nvim_create_user_command("UpscopeClear",  M.clear_output,             {})

return M
