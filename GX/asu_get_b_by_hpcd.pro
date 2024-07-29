function asu_get_B_by_HPCD, hpc, source_to_sun_dist, box, Br = Br
compile_opt idl2

coords = asu_HPCZ2BoxXYZ(hpc, box, D = source_to_sun_dist, rotator = rotator) ; bottom[2] in RSun
coords[2] /= box.dr[2]*rotator.dircos[2]
B = dblarr(3)
B[0] = asu_interpolate_3D_in_grid(box.Bx, coords)
B[1] = asu_interpolate_3D_in_grid(box.By, coords)
B[2] = asu_interpolate_3D_in_grid(box.Bz, coords)

return, B

end
