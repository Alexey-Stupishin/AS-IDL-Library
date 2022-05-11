pro l_work_mfo_box_load_by_cache_call, t, ar, xx, yy, pict_dir, km
    dll_location = 's:\Projects\Physics104_291\ProgramD64\WWNLFFFReconstruction.dll'
    mfo_box_load, t, ar, xx, yy $
                , km, 'd:\UData\SDOBoxes', 'd:\UCache\HMI', pict_dir = pict_dir, /winclose, /save_sst, /no_sel_check, aia_euv = [171], dll_location = dll_location
;                , km, 'd:\UData\SDOBoxes', 'd:\UCache\HMI', pict_dir = pict_dir, /winclose, /no_NLFFF, /no_sel_check, aia_euv = [171], dll_location = dll_location
end

pro work_mfo_box_load_by_cache

src = 'hale_find'
wdir = 's:\University\Work\NewIterations\IsolatedNormal2011-2021work'
listfilename = wdir + path_sep() + src + '.csv'
repfile = wdir + path_sep() + src + '_report.txt'

dlat = 0 ; 50
dlon = 0 ; 150
mode = 1;

res = read_ascii(listfilename, template = mfo_box_load_template(mode))

openw, U, repfile, /GET_LUN

for k = 0, n_elements(res.AR)-1 do begin
    CATCH, err_status
    if err_status ne 0 then begin
        printf, U, title + '  -> Error! ' + !ERROR_STATE.MSG
        flush, U
        CATCH, /CANCEL
        continue
    endif

    km = 1000
    if mode ne 0 then begin
        km = res.km[k]
    endif
    
    horz = [res.yfrom[k]-dlon, res.yto[k]+dlon]
    vert = [res.xfrom[k]-dlat, res.xto[k]+dlat]
    title = res.date[k] + ' ' + res.time[k] + ' ' + asu_compstr(res.AR[k]) + ' ' + asu_compstr(horz[0]) + ' ' + asu_compstr(horz[1]) + ' ' + asu_compstr(vert[0]) + ' ' + asu_compstr(vert[1]) + ' '
    l_work_mfo_box_load_by_cache_call, res.date[k] + ' ' + res.time[k], asu_compstr(res.AR[k]), horz, vert, wdir, km
    printf, U, title + '  -> Successfully'
    flush, U
    
endfor

close, U
free_lun, U

end
