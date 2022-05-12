pro l_work_mfo_box_load_by_cache_call, t, xx, yy, km, get_from, write_to
    dll_location = 's:\Projects\Physics\ProgramD64\WWNLFFFReconstruction.dll'
    mfo_box_load, t, '', xx, yy $
                , km, write_to, '' $
                , hmi_dir = get_from $
                , /no_sel_check, /save_pbox $
                , dll_location = dll_location
end

pro work_mfo_box_load_by_cache

hmi_main = 'g:\BIGData\UCache\HMI'
res_main = 's:\University\Work\Jets\conf4hmi4savRes' 
conf_dir = 's:\University\Work\Jets\conf4hmi4sav'

now = systime()
while (((pos = strpos(now, ' '))) ne -1) do strput, now, '_', pos
while (((pos = strpos(now, ':'))) ne -1) do strput, now, '_', pos

openw, U, res_main + path_sep() + 'report_' + now + '.txt', /GET_LUN

configs = file_search(filepath('config*.json', root_dir = conf_dir))
for k = 0, n_elements(configs)-1 do begin
    CATCH, err_status
    if err_status ne 0 then begin
        printf, U, write_to + '  -> Error! ' + !ERROR_STATE.MSG
        flush, U
        CATCH, /CANCEL
        continue
    endif

    write_to = 'prepare'
    
    km = 1000
    config_data = asu_read_json_config(configs[k])
    time_start = config_data["TIME_START"] 
    get_from = hmi_main + path_sep() + strmid(time_start, 0, 10)
    write_to = res_main + path_sep() + strmid(time_start, 0, 10)
    file_mkdir, write_to
    szx = config_data["WIDTH_PIX"]*0.57  
    szy = config_data["HEIGHT_PIX"]*0.57
    xx = config_data["X_CENTER"] + [-1, 1]*szx/2d
    yy = config_data["Y_CENTER"] + [-1, 1]*szy/2d

    l_work_mfo_box_load_by_cache_call, time_start, xx, yy, km, get_from, write_to
    printf, U, write_to + '  -> Successfully'
    flush, U
    
endfor

close, U
free_lun, U

end
