function asu_nearly_uniq, v, tol = tol

if n_elements(tol) eq 0 then tol = 1d-3
if n_elements(v) le 1 then return, v

vv = v[UNIQ(v, SORT(v))]
if n_elements(vv) le 1 then return, vv

vvv = vv[1:-1] - vv[0:-2]

idx = where(vvv/max(abs(v)) le tol, /NULL)
if idx ne !NULL then begin
    nn = intarr(n_elements(vv))
    cnt = 0
    for n = 0, n_elements(nn)-1 do begin
        idn = where(n eq idx, /NULL)
        if idn eq !NULL then begin
            nn[cnt] = n
            cnt++
        endif    
    endfor
    nn = nn[0:cnt-1]
    vv = vv[nn]    
endif

return, vv

end
