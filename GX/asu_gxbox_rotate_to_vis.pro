function asu_gxbox_rotate_to_vis, points, rotator

  v = double(points)
  v[0, *] *= rotator.dx
  v[0, *] -= rotator.xcen
  v[1, *] *= rotator.dy
  v[1, *] -= rotator.ycen
  v[2, *] *= rotator.dx
  v[2, *] += 1d
  in_vis = rotator.M#v
  in_vis[2, *] /= rotator.dircos[2]
  in_vis[2, *] -= 1d

  return, in_vis

end
