if exists('g:OpenBufferMap')
    unlet g:OpenBufferMap
endif
if exists('g:OpenBufferSplitMap')
    unlet g:OpenBufferSplitMap
endif
if exists('g:OpenBufferVSplitMap')
    unlet g:OpenBufferVSplitMap
endif
if exists('g:CloseBufferWindowMap')
    unlet g:CloseBufferWindowMap
endif
if exists('g:CloseBufferMap')
    unlet g:CloseBufferMap
endif
if exists('g:ForceCloseBufferMap')
    unlet g:ForceCloseBufferMap
endif

fun! BufferWindowToggle()
    lua for k in pairs(package.loaded) do if k:match("^buffer%-window") then package.loaded[k] = nil end end
    lua require("buffer-window").BufferWindowToggle()
endfun

augroup BufferWindowToggle
    autocmd!
augroup END

hi def link WhidHeader      Number
hi def link WhidSubHeader   Identifier
hi BufferWindowColor           guifg=fg   guibg=bg
