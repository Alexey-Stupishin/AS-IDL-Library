pro asu_parse_goes_xrs_ncdf_core, filename, xrsa_flux = xrsa_flux, xrsa_flags = xrsa_flags, xrsb_flux = xrsb_flux, xrsb_flags = xrsb_flags
compile_opt idl2

ncdf = ncdf_open(filename)

varids = ncdf_varidsinq(ncdf)

names = strarr(n_elements(varids))
for k = 0, n_elements(varids)-1 do begin
    var = ncdf_varinq(ncdf, varids[k])
    names[k] = var.name
endfor

; idtime = where(names eq 'time')
idxrsa = where(names eq 'xrsa_flux')
idxrsb = where(names eq 'xrsb_flux')
idxfga = where(names eq 'xrsa_flags')
idxfgb = where(names eq 'xrsb_flags')

ncdf_varget, ncdf, varids[idxrsa[0]], xrsa_flux
ncdf_varget, ncdf, varids[idxrsb[0]], xrsb_flux

ncdf_varget, ncdf, varids[idxfga[0]], xrsa_flags
ncdf_varget, ncdf, varids[idxfgb[0]], xrsb_flags

end 
