function asu_parse_goes_xrs_ncdf, fileinfo
compile_opt idl2

;{source:srcf, local:locfile, date:filedate, cadence:cadence}
ncdf = ncdf_open(fileinfo.local)

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

ncdf_varget, ncdf, varids[idxrsa[0]], xrsa
ncdf_varget, ncdf, varids[idxrsb[0]], xrsb

ncdf_varget, ncdf, varids[idxfga[0]], xrsa_flags
ncdf_varget, ncdf, varids[idxfgb[0]], xrsb_flags

return, {source:fileinfo.source, local:fileinfo.local, date:fileinfo.date, cadence:fileinfo.cadence, xrsa:xrsa, xrsa_flags:xrsa_flags, xrsb:xrsb, xrsb_flags:xrsb_flags}

end 
