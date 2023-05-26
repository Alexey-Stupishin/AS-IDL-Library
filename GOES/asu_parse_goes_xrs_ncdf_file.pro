function asu_parse_goes_xrs_ncdf_file, filename
compile_opt idl2

asu_parse_goes_xrs_ncdf_core, filename, xrsa_flux = xrsa_flux, xrsa_flags = xrsa_flags, xrsb_flux = xrsb_flux, xrsb_flags = xrsb_flags

return, {source:filename, xrsa:xrsa_flux, xrsa_flags:xrsa_flags, xrsb:xrsb_flux, xrsb_flags:xrsb_flags}

end
