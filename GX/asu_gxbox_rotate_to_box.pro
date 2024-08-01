function asu_gxbox_rotate_to_box, points, rotator

v = double(points)
Z = sqrt(1d - v[0]^2 - v[1]^2) 
v = [v[0], v[1], Z]
xyz = transpose(rotator.M)#v
xyz[1, *] += rotator.ycen
xyz[1, *] /= rotator.dy
xyz[0, *] += rotator.xcen
xyz[0, *] /= rotator.dx

return, xyz

end
