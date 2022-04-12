function asu_atm_init_profile, H, Temp, Dens
compile_opt idl2

set = hash()
set['base'] = {H:H, T:Temp, D:Dens}

return, set

end

;--------------------------------------------------------------------
function asu_atm_add_profile, set, mask_n, H, Temp, Dens
compile_opt idl2

set[mask_n] = {H:H, T:Temp, D:Dens}

return, set

end
