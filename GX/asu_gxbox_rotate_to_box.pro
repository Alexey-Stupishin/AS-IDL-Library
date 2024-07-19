function asu_gxbox_rotate_to_box, points, rotator

v = double(points)
v = [v[0]-rotator.visxcen, v[1]-rotator.visycen, 0] 
xyz = transpose(rotator.M)#v
xyz[1, *] += rotator.ycen
xyz[1, *] /= rotator.dy
xyz[0, *] += rotator.xcen
xyz[0, *] /= rotator.dx

return, xyz

end
