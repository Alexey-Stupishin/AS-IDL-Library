function asu_dyn_smooth, scan, half_slit_vert, half_slit_horz

dw = fix(half_slit_horz)
n = n_elements(scan)

smoo = scan

I0 = scan[0]
from = 0
to  = 0
for k = 0, n-1 do begin
    if scan[k] ge I0 - half_slit_vert && scan[k] le I0 + half_slit_vert then to = k else break
endfor     
pos = fix((to+from)/2d)

for k = pos, n-1 do begin
    from = k
    to  = k
    for t = k-1, fix(max([0, k-dw])), -1 do begin
        if scan[t] ge scan[k] - half_slit_vert && scan[t] le scan[k] + half_slit_vert then from = t else break
    endfor    
    for t = k+1, fix(min([n-1, k+dw])) do begin
        if scan[t] ge scan[k] - half_slit_vert && scan[t] le scan[k] + half_slit_vert then to = t else break
    endfor    

    if to-from gt 2 then begin
        res = poly_fit(indgen(to-from+1), scan[from:to], 2, yfit = yfit)
        smoo[k] = yfit[k-from]
;        if k eq 998 then begin
;            stophere = 1
;        endif    
    endif
endfor     

return, smoo 

end
 