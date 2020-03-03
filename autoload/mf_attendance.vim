let s:host = 'https://attendance.moneyforward.com'
let s:config_path = expand('~/.config/vim/mf_attendance/config')
call mkdir(fnamemodify(s:config_path, ':h'), 'p')

function! s:build_headers()
  let config = s:read_config()
  let access_token = config[1]

  return { "Authorization": "Token " . access_token }
endfunction

function! s:post(path, params)
  let url = s:host . a:path
  let response = webapi#http#post(url, a:params, s:build_headers())

  if response.status == 200
    echomsg "Done."
  else
    echoerr "Failed to requesting." . response.content
  endif
endfunction

function! s:read_file(path)
  if filereadable(a:path)
    return readfile(a:path)
  else
    return []
  endif
endfunction

function! s:read_config() abort
  let config = s:read_file(s:config_path)

  if len(config) > 0
    return config
  endif

  redraw
  echohl WarningMsg
  echo 'mf_attendance.vim requires authorization to use the API. These settings are stored in "' . s:config_path .'". If you want to revoke, do "rm ' . s:config_path . '".'
  echohl None

  let employee_id = input('employee_id: ')
  let access_token = inputsecret('access_token: ')

  if len(employee_id) == 0 || len(access_token) == 0
    let v:errmsg = 'Canceled'
    return []
  endif

  call writefile([employee_id, access_token], s:config_path)

  if !(has('win32') || has('win64'))
    call system('chmod go= '.s:config_path)
  endif

  return [employee_id, access_token]
endfunction

function! s:now()
  return strftime('%Y-%m-%dT%H:%M:%d%z')
endfunction

function! mf_attendance#create_attendance_record(event)
  let event = a:event
  let employee_id = s:read_config()[0]

  let params = {
        \ "event": a:event,
        \ "user_time": s:now(),
        \ "employee_id": employee_id,
        \ }

  call s:post('/api/external/beta_feature/attendance_records', params)
endfunction
