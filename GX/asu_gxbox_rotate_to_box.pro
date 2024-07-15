function asu_gxbox_rotate_to_box, points, rotator

v = double(points)
v[2, *] += 1d
v[2, *] *= rotator.dircos[2]
xyz = transpose(rotator.M)#v
xyz[2, *] -= 1d
xyz[2, *] /= rotator.dx
xyz[1, *] += rotator.ycen
xyz[1, *] /= rotator.dy
xyz[0, *] += rotator.xcen
xyz[0, *] /= rotator.dx

return, xyz

end
