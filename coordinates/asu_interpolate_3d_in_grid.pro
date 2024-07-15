function asu_interpolate_3D_in_grid, V, coords, missing = missing
compile_opt idl2

return, interpolate(V, coords[0,*], coords[1,*], coords[2,*], /DOUBLE, missing = missing)

end
