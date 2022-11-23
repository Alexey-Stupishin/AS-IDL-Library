function asu_dyn_smooth_symm, scan, smoo, Imod, half_slit_vert, half_slit_horz

im = asu_find_symm_center(smoo)

Imod = scan
for k = 0, im-1 do begin
    sym = 2*im - k
    if (sym lt n_elements(smoo)) then begin
        Imod(k) = min([scan(k), scan(sym)])
        Imod(sym) = Imod(k)
    endif    
endfor     

return, asu_dyn_smooth(Imod, half_slit_vert, half_slit_horz) 

end