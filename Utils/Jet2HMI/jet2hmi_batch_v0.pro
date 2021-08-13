pro l_jet2hmi_batch_v0_report, U, config_file, t0, i, ntot
    printf, U, '***** config ', strcompress(string(i+1), /remove_all), ' of ', strcompress(string(ntot), /remove_all), ' = ', file_basename(config_file) $
          , ' performed in ', asu_sec2hms(systime(/seconds)-t0, /issecs)
end

function jet2hmi_batch_v0, config_path = config_path $
                      , boxespath = boxespath, cachepath = cachepath $
                      , confoutpath = confoutpath, outpath = outpath, pictpath = pictpath $
                      , km = km, no_NLFFF = no_NLFFF 

if n_elements(km) eq 0 then km = 2000d
if n_elements(no_NLFFF) eq 0 then no_NLFFF = 0

configs = file_search(filepath('*.json', root_dir = config_path))

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
    
    openr, lun, config_file, /get_lun
    str = ""
    result = ""
    while not EOF(lun) do begin
        readf, lun, str
        result += str
    endwhile
    close, lun
    free_lun,lun
  
    jsonr = json_parse(result, /tostruct)
    id = jsonr.id 
    filename = jsonr.filename
    outfile = outpath + path_sep() + id + '.sav'
    outpict = pictpath + path_sep() + id + '.png'
    json_out = confoutpath + path_sep() + id + '.json'
    
    t0 = systime(/seconds)
    jet2hmi_conveyer_v0, id, filename, outfile, outpict, json_in = config_file, json_out = json_out, boxespath = boxespath, cachepath = cachepath, km = km, fov = fov, no_NLFFF = no_NLFFF
    l_jet2hmi_batch_report, U, config_file, t0, i, ntot
    printf, U, '  -> Successfully'
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
