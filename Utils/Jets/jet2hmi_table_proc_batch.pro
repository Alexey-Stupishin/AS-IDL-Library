pro l_jet2hmi_table_proc_batch_add, tlist, id, reslist, csvfile, savfile
    tlist.Add, {id:id, res:reslist, csvfile:csvfile, savfile:savfile}
end

pro l_jet2hmi_table_proc_batch_report, U, config_file, t0, i, ntot
    printf, U, '***** config ', strcompress(string(i+1), /remove_all), ' of ', strcompress(string(ntot), /remove_all), ' = ', file_basename(config_file) $
          , ' performed in ', asu_sec2hms(systime(/seconds)-t0, /issecs)
end

function jet2hmi_table_proc_batch, config_path = config_path, wave, csvdir, savdir

configs = file_search(filepath('*.json', root_dir = config_path))

now = systime()
while (((pos = strpos(now, ' '))) ne -1) do strput, now, '_', pos
while (((pos = strpos(now, ':'))) ne -1) do strput, now, '_', pos

filename = config_path + path_sep() + 'report_' + now + '.txt' 
openw, U, filename, /GET_LUN
                          
tt = systime(/seconds)

currid = ''
tlist = list()
reslist = list()
ncrash = 0L
ntot = n_elements(configs)
foreach config_file, configs, i do begin
    CATCH, err_status
    if err_status ne 0 then begin
        l_jet2hmi_table_proc_batch_report, U, config_file, t0, i, ntot
        printf, U, '  -> Error! ', !ERROR_STATE.MSG
        flush, U
        CATCH, /CANCEL
        ncrash++
        continue
    endif
    
    openr, lun, config_file, /get_lun
    str = ""
    result = ""
    while not EOF(lun) do begin
        readf, lun, str
        result += str
    endwhile
    close, lun
    free_lun,lun

    t0 = systime(/seconds)
    
    jsonr = json_parse(result, /tostruct)
    id = jsonr.id
    csv = csvdir + path_sep() + id + path_sep() + 'objects_m2' + path_sep() + wave + '.csv'
    sav = savdir + path_sep() + id + '_(' + asu_compstr(jsonr.ndet) + ').sav'
    
    t0 = systime(/seconds)
    
    jet2hmi_candidates_info, csv, csvinfo
    res = {id:id, csvinfo:csvinfo[jsonr.ndet-1], config:jsonr}
    
    if id ne currid then begin
        if reslist.Count() ne 0 then begin
            l_jet2hmi_table_proc_batch_add, tlist, id, reslist, csv, sav
        endif
        reslist = list()
        currid = id
    endif
    reslist.Add, res
    
    l_jet2hmi_table_proc_batch_report, U, config_file, t0, i, ntot
    printf, U, '  -> Successfully'
    flush, U
endforeach
if reslist.Count() ne 0 then begin
    l_jet2hmi_table_proc_batch_add, tlist, id, reslist, csv, sav
endif

stamp = asu_sec2hms(systime(/seconds)-tt, /issecs)
vntot = strcompress(string(ntot), /remove_all)
vncrash = strcompress(string(ncrash), /remove_all)
printf, U, '********* BATCH FINISHED SUCCESSFULLY, total ' + vntot + ' configs (' + vncrash + ' crashed) performed in ' + stamp

close, U
FREE_LUN, U

print, '******** BATCH FINISHED SUCCESSFULLY in ', stamp, ' ********'
   
return, tlist   
                      
end
