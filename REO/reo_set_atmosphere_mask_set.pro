function asu_atm_add_profile_core, set, mask_n, HTD
compile_opt idl2

lng = n_elements(HTD.H)

if set eq !NULL then begin
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
    Hn[k, sz[2]] = HTD.H[k] 
    Tn[k, sz[2]] = HTD.T[k] 
    Dn[k, sz[2]] = HTD.D[k] 
endfor

return, {H:Hn, T:Tn, D:Dn, Lmask:Lmaskn, masksN:masksNn}

end

;-----------------------------------------------------------------------------
function reo_set_atmosphere_mask_set, ptr, setlist, mask
compile_opt idl2

nn = mask[uniq(mask, sort(mask))]
base = setlist['base'] ; assert!

set = !NULL
for k = 0, n_elements(nn)-1 do begin
    mask_n = nn[k]
    HTD = setlist.hasKey(mask_n) ? setlist[mask_n] : base 
    set = asu_atm_add_profile_core(set, mask_n, HTD)
endfor

return, reo_set_atmosphere_mask(ptr, set.H, set.T, set.D, set.Lmask, set.masksN, mask)
                          
end