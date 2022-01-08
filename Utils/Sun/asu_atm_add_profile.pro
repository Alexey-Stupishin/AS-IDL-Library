function asu_atm_add_profile, set, mask_n, H, Temp, Dens

lng = n_elements(H)

if set eq !NULL then begin
    ; set = {'H':H, 'T':T, 'D':D, 'Lmask':n_elements(H), 'masksN':mask_n}
    ; set = {H:[], T:[], D:[], Lmask:[], masksN:[]}
    sz = [0, 0, 0]
    Lmaskn = lng
    masksNn = mask_n
endif else begin
    sz = size(set.H)
    if sz[0] eq 1 then sz[2] = 1
    Lmaskn = [set.Lmask, lng]
    masksNn = [set.masksN, mask_n]
endelse    

maxH = max([lng, sz[1]])
newsize = sz[2] + 1
Hn = dblarr(maxH, newsize)
Tn = dblarr(maxH, newsize)
Dn = dblarr(maxH, newsize)
for k = 0, sz[1]-1 do begin
    for j = 0, sz[2]-1 do begin
        Hn[k, j] = set.H[k, j]
        Tn[k, j] = set.T[k, j]
        Dn[k, j] = set.D[k, j]
    endfor    
endfor
for k = 0, lng-1 do begin
    Hn[k, sz[2]] = H[k] 
    Tn[k, sz[2]] = Temp[k] 
    Dn[k, sz[2]] = Dens[k] 
endfor

return, {H:Hn, T:Tn, D:Dn, Lmask:Lmaskn, masksN:masksNn}

end
