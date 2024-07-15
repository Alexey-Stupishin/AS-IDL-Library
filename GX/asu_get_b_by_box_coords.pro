function asu_get_B_by_box_coords, box, coords
compile_opt idl2

Bx = asu_interpolate_3D_in_grid(box.bx, coords)
By = asu_interpolate_3D_in_grid(box.by, coords)
Bz = asu_interpolate_3D_in_grid(box.bz, coords)

B = {x:Bx, y:By, z:Bz}

return, B

end
