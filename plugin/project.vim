let g:project_filename = "project.vim"
let g:project_temporary_filename = "project-%s.vim"
let g:project_temporary_dir = &directory

command! ProjectOpen call project#open()
command! ProjectClose call project#close()
command! ProjectSave call project#save(g:project_filename)
command! ProjectDelete call project#delete()

if g:project_autoload
	autocmd VimEnter * nested call <SID>LoadProject()
endif
if g:project_autosave
	autocmd VimLeave * call <SID>UnloadProject()
endif

function! s:LoadProject()
	let is_folder = (argc() == 1) && isdirectory(argv(0))
	if is_folder
		let has_project_file = filereadable(g:project_filename)
		if has_project_file
			call project#open()
		else
			let project_path = s:GenerateTemporaryProjectPath()
			call project#open(project_path)
		endif
    end
endfunction

function! s:UnloadProject()
	if project#exists()
		call project#save()
	endif
endfunction

function! s:GenerateTemporaryProjectPath()
	let session_dir = s:ResolvePathList(g:project_temporary_dir)
	let session_name = s:GenerateSessionName(getcwd())
	return session_dir . session_name
endfunction

function! s:GenerateSessionName(cwd)
	let escaped_cwd = substitute(a:cwd, "/", "%", "g")
	echom g:project_temporary_filename
	echom escaped_cwd
	return substitute(g:project_temporary_filename, "%s", escaped_cwd, "g")
endfunction

function! s:ResolvePathList(pathlist)
	let paths = split(a:pathlist, ",")
	for path in paths
		let resolved_path = resolve(path)
		if isdirectory(resolved_path)
			return resolved_path
		endif
	endfor
	return '.'
endfunction
