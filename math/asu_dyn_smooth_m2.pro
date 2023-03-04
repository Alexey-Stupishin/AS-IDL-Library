function asu_dyn_smooth_m2, scan, half_slit_vert, half_slit_horz

dh = fix(half_slit_vert)
dw = fix(half_slit_horz)
n = n_elements(scan)

smoo = scan

for k = 3, n-4 do begin
    if k eq 894 then begin
        stophere = 1
    endif    
    left = max([0, k-dw])
    right = min([n-1, k+dw])
    idx = where(scan[left:right] ge scan[k]-dh and scan[left:right] le scan[k]+dh, count) + left
    if count gt 1 then begin
        dn = idx[1:count-1] - idx[0:count-2]
        idx2_of_k = where(idx eq k, count2)
        if idx2_of_k le 1 then begin 
            s1 = k
        endif else begin
            idx_gap = where(dn[0:idx2_of_k-1] ne 1, count3)
            if count3 eq 0 then begin
                s1 = idx[0]
            endif else begin
                s1 = idx[idx_gap[-1]+1]
            endelse    
        endelse
                
        if idx2_of_k ge n_elements(idx)-2 then begin 
            s2 = k
        endif else begin
            idx_gap = where(dn[idx2_of_k+1:-1] ne 1, count4)
            if count4 eq 0 then begin
                s2 = idx[-1]
            endif else begin
                s2 = idx[idx_gap[0]+idx2_of_k+1]
            endelse    
        endelse
        
        if s2-s1 gt 2 then begin
            res = poly_fit(indgen(s2-s1+1), scan[s1:s2], 2, yfit = yfit)
            smoo[k] = yfit[k-s1]
        endif
    endif    
endfor    

return, smoo 

end
