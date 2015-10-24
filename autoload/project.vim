let s:has_active_project = 0
let s:active_session_path = ""

function! project#open(...)
	if s:has_active_project
		call project#close()
	endif
	let session_path = a:0 >= 1 ? a:1 : g:project_filename
	if filereadable(session_path)
		call s:ClearExistingBuffers()
		call s:LoadSession(session_path)
		call s:ClearFolderExplorerBuffer()
	else
		call project#save(session_path)
	endif
	let s:has_active_project = 1
	let s:active_session_path = session_path
	silent doautocmd user ProjectOpen
endfunction

function! project#close()
	if !s:has_active_project
		return
	endif
	let s:has_active_project = 0
	let s:active_session_path = ""
	silent doautocmd user ProjectClose
endfunction

function! project#save(...)
	let session_path = a:0 >= 1 ? a:1 : (s:has_active_project ? s:active_session_path : g:project_filename)
	call s:SaveSession(session_path)
	let s:has_active_project = 1
	let s:active_session_path = session_path
endfunction

function! project#delete(...)
	let session_path = a:0 >= 1 ? a:1 : (s:has_active_project ? s:active_session_path : g:project_filename)
	if s:has_active_project && (s:active_session_path == session_path)
		call project#close()
	endif
	call s:DeleteSession(session_path)
endfunction

function! project#exists()
	return s:has_active_project
endfunction


function! s:SaveSession(path)
	execute "mksession!" fnameescape(a:path)
endfunction

function! s:LoadSession(path)
	execute "source" fnameescape(a:path)
endfunction

function! s:DeleteSession(path)
	if filereadable(a:path)
		execute "silent !rm" fnameescape(a:path)
	endif
endfunction

function s:ClearExistingBuffers()
	let existing_buffer_ids = s:GetActiveBufferIds()
	for buffer_id in existing_buffer_ids
		execute "bwipe" buffer_id
	endfor
endfunction

function s:ClearFolderExplorerBuffer()
	let buffer_ids = s:GetActiveBufferIds()
	if len(buffer_ids) <= 1
		return
	endif
	let cwd = getcwd()
	for buffer_id in buffer_ids
		let buffer_name = bufname(buffer_id)
		let is_folder_explorer = (buffer_name == cwd) || (buffer_name == cwd . '/')
		if is_folder_explorer
			execute "bwipe" buffer_id
		endif
	endfor
endfunction

function! s:GetActiveBufferIds()
	return filter(range(1, bufnr("$")), "buflisted(v:val)")
endfunction
