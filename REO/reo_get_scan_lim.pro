function reo_get_scan_lim, vptr, scan_lim, vscanlimpos

vscanlimpos = lonarr(1, 2)
vscanlimarc = double(scan_lim)
returnCode = CALL_EXTERNAL(getenv('reo_dll_location'), 'reoGetScanLimits', vptr, vscanlimarc, vscanlimpos)
scan_lim = vscanlimarc
scanLng = vscanlimpos[1] - vscanlimpos[0] + 1

return, scanLng
    
end