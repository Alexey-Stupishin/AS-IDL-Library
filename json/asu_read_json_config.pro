function asu_read_json_config, config_file, nocase = nocase, lower = lower
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
      
    h = json_parse(result)
    hcase = 'U'
    if n_elements(nocase) ne 0 && nocase ne 0 then hcase = 'N' 
    if n_elements(lower) ne 0 && lower ne 0 then hcase = 'L' 
    
    case hcase of
        'U': h = asu_hash_to_case(h)
        'L': h = asu_hash_to_case(h, /lower)
    endcase      
    
    return, h
end