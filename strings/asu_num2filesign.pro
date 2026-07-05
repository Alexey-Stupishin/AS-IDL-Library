function asu_num2filesign_rem_lead_zeros, s

lng = strlen(s)
pos = 0
for k = 0, lng-1 do begin
    if strmid(s, k, 1) ne 0 then break
    pos++
endfor
return, strmid(s, pos)

end

function asu_num2filesign_rem_trail_zeros, s

    lng = strlen(s)
    finlng = lng
    for k = lng-1, 0, -1 do begin
        if strmid(s, k, 1) ne '0' then break
        finlng--
    endfor
    if strmid(s, k, 1) eq '.' then finlng--
    return, strmid(s, 0, finlng)

end

function asu_num2filesign, v, digits = digits, bigs = bigs, smalls = smalls, keep_zeros = keep_zeros  

if isa(v, /integer)then begin
    s = strcompress(string(v), /remove_all)
    return, s
endif

default, bigs, 1e10
default, smalls, 1e-3
default, digits, 2
if n_elements(keep_zeros) eq 0 then keep_zeros = 0

if abs(v) ge bigs then begin
    format = '(%"%15.' + string(digits) + 'e")'
    s = strcompress(string(v, format = format), /remove_all)
    if not keep_zeros then begin
        p = strpos(s, 'e')
        mant = asu_num2filesign_rem_trail_zeros(strmid(s, 0, p))
        ordr = asu_num2filesign_rem_lead_zeros(strmid(s, p+2))
        s = mant + 'e' + ordr
    endif    
    return, s
endif

if abs(v) ge 1 then begin
    format = '(%"%15.' + string(digits) + 'f")'
    s = strcompress(string(v, format = format), /remove_all)
    if not keep_zeros then begin
        s = asu_num2filesign_rem_trail_zeros(s)
    endif
    return, s
endif

n = ceil(alog10(v))

if abs(v) ge smalls then begin
    format = '(%"%15.' + string(digits-n) + 'f")'
    s = strcompress(string(v, format = format), /remove_all)
    if not keep_zeros then begin
        s = asu_num2filesign_rem_trail_zeros(s)
    endif
    
    return, s
endif

; smalls
format = '(%"%15.' + string(digits) + 'e")'
s = strcompress(string(v, format = format), /remove_all)
if not keep_zeros then begin
    p = strpos(s, 'e')
    mant = asu_num2filesign_rem_trail_zeros(strmid(s, 0, p))
    ordr = asu_num2filesign_rem_lead_zeros(strmid(s, p+2))
    s = mant + 'e-' + ordr
endif
return, s

end
 