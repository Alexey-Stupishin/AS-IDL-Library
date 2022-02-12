function asu_extract_time, s, out_style = out_style 

expr = stregex(s, '.*([0-9][0-9][0-9][0-9][/-]*[0-9][0-9][/-]*[0-9][0-9][ T][0-9][0-9][-:]*[0-9][0-9][-:]*[0-9][0-9]\.*[0-9]*)[^0-9].*',/subexpr,/extract)
; aia.lev1_euv_12s_mod.2010-06-23T161249Z.3.image.fits 

if expr[1] eq '' then return, ''

v = expr[1]
if strmid(v, strlen(v)-1) eq '.' then v = strmid(v, 0, strlen(v)-2) 

if n_elements(out_style) eq 0 then return, v

if out_style eq 'asu_time_std' then begin
    tss = anytim(v, out_style = 'UTC_EXT')
    t = string(tss.year,tss.month,tss.day,tss.hour,tss.minute,tss.second,format='(%"%04i-%02i-%02i %02i:%02i:%02i")')
endif else begin
    t = anytim(v, out_style = out_style)
    ; default anytim is UTIME
endelse    

return, t

end
