function asu_get_B_by_HPCD, hpc, source_to_sun_dist, box, Br = Br, coords = coords
compile_opt idl2

asu_box_get_coord, box, boxdata
rotator = asu_gxbox_get_rotator(boxdata)
hpcr = hpc/boxdata.rsun
coords = asu_gxbox_rotate_dxyz_to_box([hpcr, source_to_sun_dist], rotator)

sz = size(box.Bx)
if coords[0] lt 0 || coords[0] gt sz[1]-1 || coords[1] lt 0 || coords[1] gt sz[2]-1 || coords[2] lt 0 || coords[2] gt sz[3]-1 then return, !NULL 

B = dblarr(3)
B[0] = asu_interpolate_3D_in_grid(box.Bx, coords)
B[1] = asu_interpolate_3D_in_grid(box.By, coords)
B[2] = asu_interpolate_3D_in_grid(box.Bz, coords)

Br = rotator.M#B

return, B

end
