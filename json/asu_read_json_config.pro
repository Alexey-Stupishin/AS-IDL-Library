function asu_read_json_config, config_file
compile_opt idl2
  ;check the presence of the configuration file
  config_found = file_test(config_file)
  if not config_found then message, "Configuration file '" + config_file + "' not found"
  
  ;read the file content
  openr, lun, config_file,/ get_lun
  str = ""
  result = ""
  while not EOF(lun) do begin
    readf, lun, str
    result += str
  endwhile
  close, lun
  free_lun,lun
  
  return, json_parse(result)
end