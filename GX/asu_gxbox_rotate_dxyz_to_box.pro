function asu_gxbox_rotate_dxyz_to_box, points3D, rotator

  v = double(points3D)
  v = [v[0]-rotator.visxcen, v[1]-rotator.visycen, v[2]-rotator.viszcen]
  xyz = transpose(rotator.M)#v
  xyz[1, *] += rotator.ycen
  xyz[1, *] /= rotator.dy
  xyz[0, *] += rotator.xcen
  xyz[0, *] /= rotator.dx
  xyz[2, *] += rotator.zcen
  xyz[2, *] /= rotator.dz

  return, xyz

end
