function asu_get_BLOS_by_HPC, hpc, box, RSun = RSun, Mm = Mm, coords = coords
compile_opt idl2

bottom = asu_HPCZ2BoxXYZ(hpc, box, RSun = RSun, rotator = rotator)
coords = asu_get_valid_LOS_voxels(box, [bottom[0], bottom[1], 0], rotator)
if coords eq !NULL then return, !NULL

heights = coords[2, *] * rotator.dircos[2] * box.dr[2]
if n_elements(Mm) ne 0 then heights *= wcs_rsun()*1e-6

BLOS = asu_get_B_by_box_coords(box, coords)
BLOS_r = rotator.M#BLOS

LOS = {B:BLOS, Br:BLOS_r, heights:heights}

return, LOS

end
