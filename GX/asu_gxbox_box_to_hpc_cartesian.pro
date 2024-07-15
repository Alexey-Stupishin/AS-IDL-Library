function asu_gxbox_box_to_hpc_cartesian, coords, rotator
compile_opt idl2

x = (coords[0]*rotator.dx - rotator.xcen)/sqrt(1-rotator.dircos[0]^2) + rotator.visxcen
y = (coords[1]*rotator.dy - rotator.ycen)/sqrt(1-rotator.dircos[1]^2) + rotator.visycen

return, [x, y]

end
