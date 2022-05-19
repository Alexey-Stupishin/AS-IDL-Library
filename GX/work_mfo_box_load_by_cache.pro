pro l_work_mfo_box_load_by_cache_call, t, xx, yy, km, write_to, pict_dir, blim = blim, hmi_dir = hmi_dir, cache_dir = cache_dir 
    dll_location = 's:\Projects\Physics\ProgramD64\WWNLFFFReconstruction.dll'
    mfo_box_load, t, '', xx, yy $
                , km, write_to, cache_dir $
                , hmi_dir = hmi_dir $
                , dx_maxsize = 250 $
                , pict_dir = pict_dir, /winclose $
                , blim = blim $
                , /no_sel_check, /save_pbox $
                , dll_location = dll_location
end

pro work_mfo_box_load_by_cache

cache_dir = 'g:\BIGData\UCache'
hmi_main = cache_dir + path_sep() + 'HMI'
conf_dir = 's:\University\Work\Jets\conf4hmi_byHMI_2load'
;conf_dir = 's:\University\Work\Jets\conf4hmi4sav'
res_main = 'g:\BIGData\UData\Reconst\sav' 
pict_dir = 'g:\BIGData\UData\Reconst\pict' 

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
    hmi_dir = hmi_main + path_sep() + strmid(time_start, 0, 10)
    write_to = res_main + path_sep() + strmid(time_start, 0, 10)
    file_mkdir, write_to
    szx = config_data["WIDTH_PIX"]*0.57  
    szy = config_data["HEIGHT_PIX"]*0.57
    xx = config_data["X_CENTER"] + [-1, 1]*szx/2d
    yy = config_data["Y_CENTER"] + [-1, 1]*szy/2d

    l_work_mfo_box_load_by_cache_call, time_start, xx, yy, km, write_to, pict_dir, blim = 1200, cache_dir = hmi_main ; , hmi_dir = hmi_dir
    printf, U, write_to + '  -> Successfully'
    flush, U
    
endfor

close, U
free_lun, U

end
