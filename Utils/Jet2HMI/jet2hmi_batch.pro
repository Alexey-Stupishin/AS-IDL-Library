pro l_jet2hmi_batch_report, U, config_file, t0, i, ntot
    printf, U, '***** config ', strcompress(string(i+1), /remove_all), ' of ', strcompress(string(ntot), /remove_all), ' = ', file_basename(config_file) $
          , ' performed in ', asu_sec2hms(systime(/seconds)-t0, /issecs)
end

function jet2hmi_batch, config_path = config_path, _extra = _extra

configs = file_search(filepath('config*.json', root_dir = config_path))

now = systime()
while (((pos = strpos(now, ' '))) ne -1) do strput, now, '_', pos
while (((pos = strpos(now, ':'))) ne -1) do strput, now, '_', pos

filename = config_path + path_sep() + 'report_' + now + '.txt' 
openw, U, filename, /GET_LUN
                          
tt = systime(/seconds)

ncrash = 0L
ntot = n_elements(configs)
foreach config_file, configs, i do begin
    CATCH, err_status
    if err_status ne 0 then begin
        l_jet2hmi_batch_report, U, config_file, t0, i, ntot
        printf, U, '  -> Error! ', !ERROR_STATE.MSG
        flush, U
        CATCH, /CANCEL
        ncrash++
        continue
    endif
    
    t0 = systime(/seconds)
    cands = pipeline_aia_all(config_file = config_file, _extra = _extra)
    l_jet2hmi_batch_report, U, config_file, t0, i, ntot
    printf, U, '  -> Successfully, found ', pipeline_aia_cand_report(cands)
    flush, U
endforeach

stamp = asu_sec2hms(systime(/seconds)-tt, /issecs)
vntot = strcompress(string(ntot), /remove_all)
vncrash = strcompress(string(ncrash), /remove_all)
printf, U, '********* BATCH FINISHED SUCCESSFULLY, total ' + vntot + ' configs (' + vncrash + ' crashed) performed in ' + stamp

close, U
FREE_LUN, U

print, '******** BATCH FINISHED SUCCESSFULLY in ', stamp, ' ********'
   
return, vntot   
                      
end
