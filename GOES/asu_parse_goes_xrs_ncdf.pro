function asu_parse_goes_xrs_ncdf, fileinfo
compile_opt idl2

asu_parse_goes_xrs_ncdf_core, fileinfo.local, xrsa_flux = xrsa_flux, xrsa_flags = xrsa_flags, xrsb_flux = xrsb_flux, xrsb_flags = xrsb_flags 

return, {source:fileinfo.source, local:fileinfo.local, date:fileinfo.date, cadence:fileinfo.cadence, xrsa:xrsa_flux, xrsa_flags:xrsa_flags, xrsb:xrsb_flux, xrsb_flags:xrsb_flags}

end 
