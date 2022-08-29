function asu_gxbox_rotate_line, line3D, rotator

v = line3D
v[0, *] *= rotator.dx
v[0, *] -= rotator.xcen
v[1, *] *= rotator.dy
v[1, *] -= rotator.ycen
v[2, *] *= rotator.dx
v[2, *] += 1d
line = rotator.M#v * rotator.rsun
line[2, *] -= rotator.rsun

return, line

end
