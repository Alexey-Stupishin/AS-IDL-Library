function asu_gxbox_hpc_to_box_cartesian, hpc, rotator
compile_opt idl2

x = ((hpc[0] - rotator.visxcen)*sqrt(1-rotator.dircos[0]^2) + rotator.xcen)/rotator.dx 
y = ((hpc[1] - rotator.visycen)*sqrt(1-rotator.dircos[1]^2) + rotator.ycen)/rotator.dy

return, [x, y]

end
