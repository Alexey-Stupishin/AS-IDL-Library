function jsoc_get_query_ex, ds, starttime, stoptime, wave, segment = segment, cadence = cadence $
                          , t_ref = t_ref, x = x, y = y, width = width, height = height $
                          , processing = processing, no_tracking = no_tracking

if n_elements(no_tracking) eq 0 then no_tracking = 0

t1 = str_replace(str_replace(anytim(starttime,/cc),'-','.'),'T','_')
t1 = strmid(t1,0,19)+'_TAI'
t2 = str_replace(str_replace(anytim(stoptime,/cc),'-','.'),'T','_')
t2 = strmid(t2,0,19)+'_TAI'
use_cadence = keyword_set(cadence) && strlen(cadence) gt 0
if keyword_set(t_ref) and (n_elements(x) eq 1) and (n_elements(y) eq 1) then begin
    if n_elements(width) ne 1 then width=100
    if n_elements(height) ne 1 then height=100
    t_ref_= str_replace(str_replace(anytim(t_ref,/cc),'-','.'),'T','_')
    t_ref_= strmid(t_ref_,0,19)+'_TAI'
    processing = 'im_patch,'
    processing += 't_start=' + t1 + ',t_stop=' + t2 + ',t='
    processing += (no_tracking ? '1' : '0')
    processing += ',r=1,c=0,cadence='
  
    processing += use_cadence ? cadence : '1s'
   
    processing += ',locunits=arcsec,boxunits=pixel,t_ref=' $
               + t_ref_ $
               + ',x=' + strcompress(x,/remove) + ',y=' + strcompress(y,/remove) $
               + ',width=' + strcompress(width,/remove) + ',height=' + strcompress(height,/remove)
               
    processing = str_replace(processing, '=', '%3d')
endif

res = ds + '[' + t1 + '-' + t2
if use_cadence then res += '@' + cadence
res += ']'

if keyword_set(wave) then res = res + '[' + strjoin(sstring(wave),',') + ']'
if keyword_set(segment) then res = res + '{' + segment + '}'

return,res
  
end