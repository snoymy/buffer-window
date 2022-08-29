local api = vim.api
local fn = vim.fn
local vim = vim
local buf, win
local position = 0
local buffers_number = {}

local function center(str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

local function CreateWindow()
    vim.g["Open_From_Window_ID"] = fn.win_getid()

    buf = api.nvim_create_buf(false, true)
    local border_buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'filetype', 'whid')

    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local win_height = math.ceil(height * 0.4 - 4)
    local win_width = math.ceil(width * 0.6)
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local border_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1
    }

    local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
    }

    local border_lines = { '┌' .. string.rep('─', win_width/2 - #' Buffer Window '/2 + 1) .. ' Buffer Window ' .. string.rep('─', win_width/2 - #' Buffer Window '/2) .. '┐' }
    local middle_line = '│' .. string.rep(' ', win_width) .. '│'
    for i=1, win_height do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '└' .. string.rep('─', win_width) .. '┘')
    api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    local border_win = api.nvim_open_win(border_buf, true, border_opts)
    win = api.nvim_open_win(buf, true, opts)
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

    api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it

    -- we can add title already here, because first line will never change
    -- api.nvim_buf_set_lines(buf, 0, -1, false, { center('Buffer Window'), '', ''})
    api.nvim_buf_add_highlight(buf, -1, 'BufferWindowColor', 0, 0, -1)
    for i=1, win_height+2 do
        api.nvim_buf_add_highlight(border_buf, -1, 'BufferWindowColor', i-1, 0, -1)
    end
    api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:BufferWindowColor')

    api.nvim_command('highlight CursorLine guibg=#555555 guifg=fg')
    api.nvim_win_set_cursor(win, {1, 0})
    api.nvim_buf_set_option(buf, 'modifiable', false)

    vim.g["Buffer_Window_Open"] = 1
    vim.g["Buffer_Window_win"] = win
end

local function SetMappings()
  local mappings = {
    k = 'MoveWindowCursor(-1)',
    j = 'MoveWindowCursor(1)',
    ['1'] = 'MoveWindowCursorTo(1)',
    ['2'] = 'MoveWindowCursorTo(2)',
    ['3'] = 'MoveWindowCursorTo(3)',
    ['4'] = 'MoveWindowCursorTo(4)',
    ['5'] = 'MoveWindowCursorTo(5)',
    ['6'] = 'MoveWindowCursorTo(6)',
    ['7'] = 'MoveWindowCursorTo(7)',
    ['8'] = 'MoveWindowCursorTo(8)',
    ['9'] = 'MoveWindowCursorTo(8)',
    ['0'] = 'MoveWindowCursorTo(10)'
  }
  local custom_OpenBuffer_mapping = vim.g["OpenBufferMap"]
  local custom_OpenBufferSplit_mapping = vim.g["OpenBufferSplitMap"]
  local custom_OpenBufferVSplit_mapping = vim.g["OpenBufferVSplitMap"]
  local custom_CloseBufferWindow_mapping = vim.g["CloseBufferWindowMap"]
  local custom_CloseBuffer_mapping = vim.g["CloseBufferMap"]
  local custom_ForceCloseBuffer_mapping = vim.g["ForceCloseBufferMap"]

  if custom_OpenBuffer_mapping == nil then
        mappings['<cr>'] = 'OpenBuffer()'
  else
        for _,v in pairs(custom_OpenBuffer_mapping) do
            mappings[v] = 'OpenBuffer()'
        end
  end
  if custom_OpenBufferSplit_mapping == nil then
        mappings['s<cr>'] = 'OpenBuffer("s")'
  else
        for _,v in pairs(custom_OpenBufferSplit_mapping) do
            mappings[v] = 'OpenBuffer("s")'
        end
  end
  if custom_OpenBufferVSplit_mapping == nil then
        mappings['v<cr>'] = 'OpenBuffer("v")'
  else
        for _,v in pairs(custom_OpenBufferVSplit_mapping) do
            mappings[v] = 'OpenBuffer("v")'
        end
  end
  if custom_CloseBufferWindow_mapping == nil then
        mappings['<Esc>'] = 'BufferWindowClose()'
        mappings['q'] = 'BufferWindowClose()'
  else
        for _,v in pairs(custom_CloseBufferWindow_mapping) do
            mappings[v] = 'BufferWindowClose()'
        end
  end
  if custom_CloseBuffer_mapping == nil then
        mappings['u'] = 'CloseBuffer(false)'
  else
        for _,v in pairs(custom_CloseBuffer_mapping) do
            mappings[v] = 'CloseBuffer(false)'
        end
  end
  if custom_ForceCloseBuffer_mapping == nil then
        mappings['!u'] = 'CloseBuffer(true)'
  else
        for _,v in pairs(custom_ForceCloseBuffer_mapping) do
            mappings[v] = 'CloseBuffer(true)'
        end
  end

  for k,v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"buffer-window".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
  local other_chars = {
  --  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'l', 'n', 'o', 'p', 'r', 'w', 'x', 'y', 'z'
  }
  for k,v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
  end
end

function GetFilename(path)
    local ret = path:match("^.+/(.+)$")
    if ret == nil then
        return path 
    else
        return ret
    end
end

local function swap(t, a, b)
    local temp

    temp = t[a]
    t[a] = t[b]
    t[b] = temp
end

local function GetBufferList()
    local buffers_list = api.nvim_list_bufs()
    local listed_buffers = {}
    buffers_number = {}

    for _,v in pairs(buffers_list) do
        if fn.buflisted(v) == 1 then
            local modfiled = (fn.getbufinfo(v)[1].changed == 1 and "+" or " ")
            local bufname = GetFilename(fn.bufname(v))
            local filepath = (bufname == "" and "" or " ("..fn.expand(string.format("#%d:p", v))..")")
            if bufname == "" then bufname = "[No Name]" end

            table.insert(listed_buffers, modfiled..bufname..filepath)
            table.insert(buffers_number, v)
        end
    end

    for i=1 , #buffers_number-1 do
        local maxidx = i
        for j=i+1 , #buffers_number do
            local lastused1 = fn.getbufinfo(buffers_number[maxidx])[1].lastused
            local lastused2 = fn.getbufinfo(buffers_number[j])[1].lastused
            if lastused2 > lastused1 then
                maxidx = j
            end
        end
        swap(buffers_number, maxidx, i)
        swap(listed_buffers, maxidx, i)
    end
    
    for i = 1, #listed_buffers do
        listed_buffers[i] = (i <= 10 and " ["..(i%10).."]" or "    ")..listed_buffers[i]
    end

    return listed_buffers
end

local function UpdateWindowBuffer()
    local buffers = GetBufferList()

    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, buffers)
    api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function MoveWindowCursor(dir)
    local new_pos
    if dir < 0 then
        new_pos = math.max(1, api.nvim_win_get_cursor(win)[1] + dir)
    else
        new_pos = math.min(api.nvim_buf_line_count(buf), api.nvim_win_get_cursor(win)[1] + dir)
    end
    api.nvim_win_set_cursor(win, {new_pos, 0})
end

local function BufferWindowClose()
  api.nvim_win_close(vim.g["Buffer_Window_win"], true)
  fn.win_gotoid(vim.g["Open_From_Window_ID"])
  vim.g["Buffer_Window_Open"] = 0
end

local function BufferWindowOpen()
    CreateWindow()
    UpdateWindowBuffer()
    SetMappings()
end

local function OpenBuffer(mode)
  local pos = api.nvim_win_get_cursor(win)[1]
  if pos == 0 then return end
  BufferWindowClose()

  if mode == nil then api.nvim_command('buffer '..buffers_number[pos])
  elseif mode == "v" then api.nvim_command('vert sbuffer '..buffers_number[pos])
  elseif mode == "s" then api.nvim_command('sbuffer '..buffers_number[pos])
  elseif mode == "t" then api.nvim_command('buffer '..buffers_number[pos].." | tab split")
  end
end

local function CloseBuffer(force)
  local pos = api.nvim_win_get_cursor(win)[1]

  if force == true then
      if pos == 1 then
          BufferWindowClose()
          api.nvim_command('buffer '..buffers_number[pos+1])
          api.nvim_command('bd! '..buffers_number[pos])
          table.remove(buffers_number, pos)
          BufferWindowOpen()
      else
          api.nvim_command('bd! '..buffers_number[pos])
          table.remove(buffers_number, pos)
          UpdateWindowBuffer()
      end
  else
      if fn.getbufinfo(buffers_number[pos])[1].changed == 1 then
          print("Please save buffer before unload or use !u to unload without save.")
      else
          if pos == 1 then
              BufferWindowClose()
              api.nvim_command('buffer '..buffers_number[pos+1])
              api.nvim_command('bd '..buffers_number[pos])
              table.remove(buffers_number, pos)
              BufferWindowOpen()
          else
              api.nvim_command('bd '..buffers_number[pos])
              table.remove(buffers_number, pos)
              UpdateWindowBuffer()
          end
      end
  end
end

local function MoveWindowCursorTo(line)
    if line == api.nvim_win_get_cursor(win)[1] then
        OpenBuffer()
    elseif line <= api.nvim_buf_line_count(buf) then
        api.nvim_win_set_cursor(win, {line, 0})
    end
end

local function BufferWindowToggle()
    if vim.g["Buffer_Window_Open"] == 1 then
        BufferWindowClose()
    else
        BufferWindowOpen()
    end
end

return {
    BufferWindowToggle = BufferWindowToggle,
    BufferWindowOpen = BufferWindowOpen,
    BufferWindowClose = BufferWindowClose,
    CreateWindow = CreateWindow,
    OpenBuffer = OpenBuffer,
    MoveWindowCursor = MoveWindowCursor,
    CloseBuffer = CloseBuffer,
    MoveWindowCursorTo = MoveWindowCursorTo
}
