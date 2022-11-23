function asu_sec2HMS, hrminsec, issecs = issecs

hrmin = long(hrminsec)/60
sec = hrminsec - hrmin*60 
dhr = long(hrmin)/60
mins = hrmin - dhr*60
days = long(dhr)/24
hr = dhr - days*24

if n_elements(issecs) eq 0 then issecs = 0

if days eq 0 && hr eq 0 && mins eq 0 then begin
    hms_string = strcompress(long(hrminsec), /remove_all)
    hms_string += issecs ? ' seconds' : 's'  
endif else begin
    hms_string = string(long(sec), format='(%"%02d")') + 's'
    if days eq 0 && hr eq 0 then begin
        hms_string = strcompress(long(mins), /remove_all) + 'm ' + hms_string 
    endif else begin
        hms_string = string(long(mins), format='(%"%02d")') + 'm ' + hms_string
        if days eq 0 then begin
            hms_string = strcompress(long(hr), /remove_all) + 'h ' + hms_string
        endif else begin
            hms_string = string(long(hr), format='(%"%02d")') + 'h ' + hms_string
            hms_string = strcompress(long(days), /remove_all) + 'd ' + hms_string
        endelse    
    endelse
    
    if issecs then begin
        hms_string = strcompress(long(hrminsec), /remove_all) + ' seconds (' + hms_string + ')'
    endif
endelse

return, hms_string

end
