pro asu_download_aia_by_date, ratan_dir, cdate, waves

syear = !NULL
smonth = !NULL
sday = !NULL
exprd = stregex(cdate, '([0-9][0-9][0-9][0-9])[/-]*([0-9][0-9])[/-]*([0-9][0-9])',/subexpr,/extract)
if n_elements(exprd) ne 4 then begin
    print, "----- This date (" + cdate + ") cannot be parsed!"
endif

sid = exprd[1] + exprd[2] + exprd[3]

ratanfiles = file_search(ratan_dir + path_sep() + sid + '*.fits')

aia_dir = ratan_dir + path_sep() + 'AIA'
file_mkdir, aia_dir
foreach rfile, ratanfiles, ir do begin
    rat = readfits(rfile, hdr)
    rtime = fxpar(hdr, 'TIME-OBS')
    exprt = stregex(rtime, '([0-9][0-9]:[0-9][0-9]:[0-9][0-9]).*',/subexpr,/extract)
    if n_elements(exprt) ne 2 || strlen(exprt[1]) ne 8 then continue
    
    qtime = exprd[1] + '-' +  exprd[2] + '-' +  exprd[3] + ' ' + exprt[1]
    asu_download_aia_by_time, ratan_dir, aia_dir, qtime, waves
endforeach
  
end
 