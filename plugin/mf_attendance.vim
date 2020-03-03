let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_mf_attendance')
  finish
endif

command! ClockIn call mf_attendance#create_attendance_record('clock_in')
command! ClockOut call mf_attendance#create_attendance_record('clock_out')
command! StartBreak call mf_attendance#create_attendance_record('start_break')
command! EndBreak call mf_attendance#create_attendance_record('end_break')

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_mf_attendance = 1
