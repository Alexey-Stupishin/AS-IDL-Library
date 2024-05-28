function asu_atm_init_profile, H, Temp, Dens, fixrange = fixrange
compile_opt idl2

if n_elements(fixrange) eq 0 then fixrange = 0
set = hash()
set['base'] = {H:H, T:Temp, D:Dens, fixed:fixrange}

return, set

end

;--------------------------------------------------------------------
function asu_atm_add_profile, set, mask_n, H, Temp, Dens, fixrange = fixrange
compile_opt idl2

if n_elements(fixrange) eq 0 then fixrange = 0
set[mask_n] = {H:H, T:Temp, D:Dens, fixed:fixrange}

return, set

end
