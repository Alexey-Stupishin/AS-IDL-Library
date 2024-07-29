function asu_HPCZ2BoxXYZ, hpc, box, Z = Z, D = D, RSun = RSun, rotator = rotator
; HPC in Rsun or arcsec, if key
; Z in Rsun or km, if key
compile_opt idl2

asu_box_get_coord, box, boxdata
rotator = asu_gxbox_get_rotator(boxdata)

if n_elements(Z) eq 0 then begin
    Z = n_elements(D) ne 0 ? D/rotator.dircos[2] - 1 : 0
endif

if n_elements(RSun) eq 0 then hpc /= boxdata.rsun

return, asu_gxbox_rotate_to_box([hpc[0], hpc[1], Z], rotator)
; return, asu_gxbox_hpc_to_box_cartesian(hpc, rotator)

end
