function asu_HPCZ2BoxXYZ, hpc, box, Z = Z, arcsec = arcsec, km = km, rotator = rotator
; HPC in Rsun or arcsec, if key
; Z in Rsun or km, if key
compile_opt idl2

if n_elements(Z) eq 0 then Z = 0

asu_box_get_coord, box, boxdata
rotator = asu_gxbox_get_rotator(boxdata)

if n_elements(arcsec) ne 0 then hpc /= boxdata.rsun
if n_elements(km) ne 0 then Z /= wcs_rsun()*1d-3

return, asu_gxbox_rotate_to_box([hpc[0], hpc[1], Z], rotator)
; return, asu_gxbox_hpc_to_box_cartesian(hpc, rotator)

end
