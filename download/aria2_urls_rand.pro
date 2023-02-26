pro aria2_urls_rand, urls, dir, output = output
  
  aria2cpath = file_dirname((ROUTINE_INFO('aria2_urls_rand', /source)).path, /mark)
  
  if !version.OS_FAMILY eq 'unix' then begin ;use aria2c binary from the systim in unix based OS
    aria2cpath=''
  endif
  
  aria2c = aria2cpath + 'aria2c -c --auto-file-renaming=false '
  if not keyword_set(dir) then dir=GETENV('IDL_TMPDIR')
  if not file_test(dir,/directory) then file_mkdir,dir
  for i=0,100 do begin
    filename=randomstring(seed,5)+'.txt'
    filename=filepath(filename,root=dir)
    if not file_test(filename) then break
  endfor
  openw, Unit, filename, /GET_LUN 
  printf,unit,urls
  free_lun,unit

  if not file_test(filename) then break
  
  cmd = aria2c+' -d '+dir+' -i '+filename
  print, cmd
  spawn, cmd, output ;, /log_output
  file_delete, filename
end