; RATAN-600 fits downloader
; 
; Call examples:
;   rtu_download_ratan_fits, dates = '2015-02-05'
;   rtu_download_ratan_fits, dates = ['2015-02-05', '2015-02-06', '2015-02-07']
;   rtu_download_ratan_fits, dates = ['20150101', '20150102'], loc_dir = 'c:\temp'
;   rtu_download_ratan_fits, date_range = ['2015/01/25', '2015/02/03'], loc_dir = 'c:\temp'
; 
; Parameters description:
; 
; Parameters optional (in):
;   (in)      dates        (string or string array)     required dates
;   (in)      date_range   (string[2])                  required date range
;   (in)      loc_dir      (string)                     Local directory to save fits. Current IDL directory by default
;
;  Either 'dates' or 'date_range' parameters should be set. If both are set, they will be combined
;  Date format patterns can be YYYY/MM/DD or YYYY-MM-DD or YYYYMMDD; 
;  Utility creates directory subtree in locad directory (YYYY/MM/DD)
;   
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2017-2020
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;

;------------------------------------------------------------
pro l_asu_download_ratan_fits_parse_date, cdate, syear, smonth, sday

syear = !NULL
smonth = !NULL
sday = !NULL
expr = stregex(cdate, '([0-9][0-9][0-9][0-9])[/-]*([0-9][0-9])[/-]*([0-9][0-9])',/subexpr,/extract)
if n_elements(expr) eq 4 then begin
    syear = expr[1]
    smonth = expr[2]
    sday = expr[3]
endif

end

;------------------------------------------------------------
pro l_asu_download_ratan_fits_find_fits, outlist, syear, smonth, sday, usefits

foundfits = strarr(64)
nfits = 0
pattern = syear + smonth + sday

foreach filename, outlist do begin
    expr = stregex(filename, '.+(' + pattern + '_[0-9]*_sun.+\.fits)',/subexpr,/extract)
    if n_elements(expr) eq 2 and strlen(expr[1]) gt 0 then begin
        foundfits[nfits] = expr[1]
        nfits++
    end
endforeach

usefits = !NULL
if nfits gt 0 then usefits = foundfits[0:nfits-1]

end

;------------------------------------------------------------
pro l_asu_download_ratan_fits_proceed_range, date_range, rdates

rdates = date_range[0]
if n_elements(date_range) eq 1 then begin
    return
endif    

l_asu_download_ratan_fits_parse_date, date_range[0], syear0, smonth0, sday0
from = julday(fix(smonth0), fix(sday0), fix(syear0), 12, 0, 0)
l_asu_download_ratan_fits_parse_date, date_range[1], syear1, smonth1, sday1
to = julday(fix(smonth1), fix(sday1), fix(syear1), 12, 0, 0)

if to le from then begin
    return
endif

n = fix(to - from) + 1
rdates = strarr(n)
rdates[0] = date_range[0]
for i = 1,n-1 do begin
    from += 1
    caldat, from, Month, Day, Year
    rdates[i] = string(Year, FORMAT = '(I04)') + '-' + string(Month, FORMAT = '(I02)') + '-' + string(Day, FORMAT = '(I02)') 
endfor    

end

;------------------------------------------------------------
pro rtu_download_ratan_fits, dates = dates, date_range = date_range, loc_dir = loc_dir $
                           , aia_waves = aia_waves, mag = mag, cont = cont, jddate = jddate, jds = jds, rsuns = rsuns 
; date pattern: YYYY/MM/DD or YYYY-MM-DD or YYYYMMDD

if ~keyword_set(loc_dir) then cd, current = loc_dir
if ~keyword_set(dates) and ~keyword_set(date_range) then begin
    print, "Either 'dates' or 'date_range' parameters should be set!"
    return
endif    

if keyword_set(date_range) then begin
    l_asu_download_ratan_fits_proceed_range, date_range, rdates
    if ~keyword_set(dates) then begin
        dates = rdates
    endif else begin
        nd = n_elements(dates)
        ndr = n_elements(rdates) 
        t = strarr(nd + ndr)
        t[0:nd-1] = dates
        t[nd:nd+ndr-1] = rdates
        dates = t
    endelse
endif

ratan_path = "www.spbf.sao.ru/data/ratan"
; pattern "2015/12/20151215_135339_sun-24_out.fits"

jddate = strarr(n_elements(dates))
jds = dblarr(n_elements(dates))
rsuns = dblarr(n_elements(dates))
foreach cdate, dates, idat do begin
    l_asu_download_ratan_fits_parse_date, cdate, syear, smonth, sday
    if sday eq !NULL then begin
        print, "----- This date (" + cdate + ") cannot be parsed!"
    endif else begin
        print, "----- " + syear + "-" + smonth + "-" + sday + " -----"
        check_path = ratan_path + '/' + syear + '/' + smonth
        check_out = loc_dir + path_sep() + syear + path_sep() + smonth + path_sep() + sday
        file_mkdir, check_out 
        check_out_for_ratan = check_out + path_sep()
        sock_dir, check_path, outlist
        l_asu_download_ratan_fits_find_fits, outlist, syear, smonth, sday, usefits
        if usefits ne !NULL then begin
            check_path = check_path + '/'
            for i = 0, n_elements(usefits)-1 do begin
                ratan_fits = check_out_for_ratan + usefits[i]
                status = asu_try_download(check_path+usefits[i], ratan_fits)
                rat = readfits(ratan_fits, hdr, /silent)
                rtime = fxpar(hdr, 'TIME-OBS')
                exprt = stregex(rtime, '([0-9][0-9]:[0-9][0-9]:[0-9][0-9]).*',/subexpr,/extract)
                
                if arg_present(jddate) and arg_present(jds) and arg_present(rsuns) then begin
                    jddate[idat] = cdate
                    hms = stregex(rtime, '([0-9][0-9]):([0-9][0-9]):([0-9][0-9]).*',/subexpr,/extract)
                    jds[idat] = julday(fix(smonth), fix(sday), fix(syear), fix(hms[1]), fix(hms[2]), fix(hms[3]))
                    rsuns[idat] = fxpar(hdr, 'SOLAR_R')
                endif
                
                if n_elements(exprt) eq 2 && strlen(exprt[1]) eq 8 then begin
                    qtime = syear + "-" + smonth + "-" + sday + " " + rtime
                    if keyword_set(aia_waves) then begin
                        aia_dir = check_out + path_sep() + 'AIA'
                        file_mkdir, aia_dir
                        asu_download_aia_by_time, check_out, aia_dir, qtime, aia_waves
                    endif
                    if keyword_set(mag) then begin
                        hmi_m_dir = check_out + path_sep() + 'Magnetogram'
                        file_mkdir, hmi_m_dir
                        filename = asu_jsoc_get_fits(qtime, 720, 'hmi.M_720s', 'magnetogram', check_out, hmi_m_dir) ; , err = err
                    endif
                    if keyword_set(cont) then begin
                        cont_dir = check_out + path_sep() + 'Continuum'
                        file_mkdir, cont_dir
                        filename = asu_jsoc_get_fits(qtime, 720, 'hmi.Ic_noLimbDark_720s', 'continuum', check_out, cont_dir) ; , err = err
                    endif
                endif
            endfor  
        endif  
    endelse
endforeach

end
