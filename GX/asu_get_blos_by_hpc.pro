function asu_get_BLOS_by_HPC, hpc, box, arcsec = arcsec, km = km, heights = heights, coords = coords
compile_opt idl2

bottom = asu_HPCZ2BoxXYZ(hpc, box, arcsec = arcsec, rotator = rotator)
coords = asu_get_valid_LOS_voxels(box, [bottom[0], bottom[1], 0], rotator)
if coords eq !NULL then begin
    heights = !NULL
    return, !NULL
endif

heights = coords[2, *] * rotator.dircos[2] * box.dr[2]
if n_elements(km) ne 0 then heights *= wcs_rsun()*1e-3

BLOS = asu_get_B_by_box_coords(box, coords)
return, BLOS

end
