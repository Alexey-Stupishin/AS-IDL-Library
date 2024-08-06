function asu_get_B_by_HPCZ, x, y, above_photosphere_Mm, box, Br = Br, coords = coords

compile_opt idl2

Br = !NULL
coords = !NULL

asu_box_get_coord, box, boxdata
rotator = asu_gxbox_get_rotator(boxdata)

xr = double(x)/rotator.rsun
yr = double(y)/rotator.rsun
radius = above_photosphere_Mm/695.7 + 1
z2 = radius^2 - xr^2 - yr^2
if z2 lt 0 then return, !NULL
zr = sqrt(z2)
v = [xr, yr, zr]

v -= [rotator.visxcen, rotator.visycen, rotator.viszcen]
coords = transpose(rotator.M)#v
coords += [rotator.xcen, rotator.ycen, rotator.zcen]

coords /= [rotator.dx, rotator.dy, rotator.dz]
sz = size(box.Bx)
if coords[0] lt 0 || coords[0] gt sz[1]-1 || coords[1] lt 0 || coords[1] gt sz[2]-1 || coords[2] lt 0 || coords[2] gt sz[3]-1 then return, !NULL 

B = dblarr(3)
B[0] = asu_interpolate_3D_in_grid(box.Bx, coords)
B[1] = asu_interpolate_3D_in_grid(box.By, coords)
B[2] = asu_interpolate_3D_in_grid(box.Bz, coords)

Br = rotator.M#B

return, B
  
end
