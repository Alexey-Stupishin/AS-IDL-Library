function asu_parse_goes_xrs_ncdf, file
compile_opt idl2

ncdf = ncdf_open(file)

varids = ncdf_varidsinq(ncdf)

names = strarr(n_elements(varids))
for k = 0, n_elements(varids)-1 do begin
    var = ncdf_varinq(ncdf, varids[k])
    names[k] = var.name
endfor

; idtime = where(names eq 'time')
idxrsa = where(names eq 'xrsa_flux')
idxrsb = where(names eq 'xrsb_flux')

ncdf_varget, ncdf, varids[idxrsa[0]], xrsa
ncdf_varget, ncdf, varids[idxrsb[0]], xrsb

return, {xrsa:xrsa, xrsb:xrsb}

end 
