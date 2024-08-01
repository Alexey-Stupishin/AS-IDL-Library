function asu_HPCZ2BoxXYZ, hpc, box, rotator, RSun = RSun
; HPC in Rsun or arcsec, if key
; Z in Rsun above photosphere

compile_opt idl2

asu_box_get_coord, box, boxdata
rotator = asu_gxbox_get_rotator(boxdata)

if n_elements(RSun) eq 0 then hpc /= boxdata.rsun

return, asu_gxbox_rotate_to_box(hpc, rotator)

end
