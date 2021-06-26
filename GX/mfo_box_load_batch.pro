pro l_mfo_box_load_batch_report, U, qfile, t0, i, ntot
    printf, U, '***** query ' + asu_compstr(i+1) + ' of ' + asu_compstr(ntot) + ' = ' + file_basename(qfile) $
           + ' performed in ' + asu_sec2hms(systime(/seconds)-t0, /issecs)
end

pro mfo_box_load_batch, hmiquery_path, out_dir, tmp_dir, dx_km = dx_km $
                      , rlim = rlim, for_start = for_start, for_stop = for_stop, for_mid = for_mid, nlfff = nlfff $
                      , _extra = _extra
; 's:\University\Work\Jets\New' 

hmiqueries = file_search(filepath('config*.json', root_dir = hmiquery_path))

now = asu_str2filename(systime())

filename = hmiquery_path + path_sep() + 'report_' + now + '.txt' 
openw, U, filename, /GET_LUN
                          
tt = systime(/seconds)

if n_elements(dx_km) eq 0 then dx_km = 1000
if n_elements(rlim) eq 0 then rlim = 0.95
if n_elements(for_start) eq 0 then for_start = 1
if n_elements(for_stop) eq 0 then for_stop = 0
if n_elements(for_mid) eq 0 then for_mid = 0
if n_elements(nlfff) eq 0 then nlfff = 0

pict_dir = hmiquery_path + path_sep() + 'contours_' + now
file_mkdir, pict_dir
     
if nlfff eq 0 then begin
    contour_only = 1
    no_NLFFF = 1
endif else begin
    contour_only = 0
    no_NLFFF = 0
endelse

rlim *= 935
rlim *= rlim

qlist = list()
ncrash = 0L
foreach query_file, hmiqueries, i do begin
    qdata = asu_read_json_config(query_file)
    x = qdata["X_CENTER"]
    y = qdata["Y_CENTER"]
    if x^2 + y^2 ge rlim then begin
        printf, U, 'file ' + query_file + ': is out or close to the limb'
        continue
    endif    
    
    w = qdata["WIDTH_PIX"]
    h = qdata["HEIGHT_PIX"]
    xx = [x - w/2, x + w/2]
    yy = [y - h/2, y + h/2]
    
    start = anytim(qdata["TIME_START"])
    stop = anytim(qdata["TIME_STOP"])
    if for_start ne 0 then qlist.Add, {t:start, x:xx, y:yy, cfile:query_file}
    if for_stop ne 0 then qlist.Add, {t:stop, x:xx, y:yy, cfile:query_file}
    if for_mid ne 0 then qlist.Add, {t:(stop+start)/2, x:xx, y:yy, cfile:query_file}
endforeach

printf, U, ' '
printf, U, '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
printf, U, ' '

ntot = qlist.Count()
foreach qpars, qlist, i do begin
    CATCH, err_status
    if err_status ne 0 then begin
        l_mfo_box_load_batch_report, U, qpars.cfile, t0, i, ntot
        printf, U, '  -> Error! ', !ERROR_STATE.MSG
        flush, U
        CATCH, /CANCEL
        ncrash++
        continue
    endif
    
    t0 = systime(/seconds)
    mfo_box_load, qpars.t, "batch", qpars.x, qpars.y, dx_km, out_dir, tmp_dir $
                ;, contour_only = contour_only $
                , no_sel_check = 1, /winclose, no_NLFFF = no_NLFFF $
                , pict_dir = pict_dir, _extra = _extra 
    l_mfo_box_load_batch_report, U, qpars.cfile, t0, i, ntot
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
                          
end
