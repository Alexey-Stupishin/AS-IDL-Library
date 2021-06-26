;------------------------------------------------------------
pro l_asu_proceed_dates_parse_date, cdate, syear, smonth, sday

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
pro l_asu_proceed_dates_proceed_range, date_range, rdates

rdates = date_range[0]
if n_elements(date_range) eq 1 then begin
    return
endif    

l_asu_proceed_dates_parse_date, date_range[0], syear0, smonth0, sday0
from = julday(fix(smonth0), fix(sday0), fix(syear0), 12, 0, 0)
l_asu_proceed_dates_parse_date, date_range[1], syear1, smonth1, sday1
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
pro asu_proceed_dates, dates = dates, date_range = date_range, datestruct

datestruct = !NULL

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

datestruct =  = replicate({syear:'', smonth:'', sday:''}, n_elements(dates))

foreach cdate, dates, i do begin
    l_asu_proceed_dates_parse_date, cdate, syear, smonth, sday
    datestruct[i].syear = syear 
    datestruct[i].smonth = smonth 
    datestruct[i].sday = sday 
end

end
