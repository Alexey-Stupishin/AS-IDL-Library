function asu_gxbox_get_rotator, boxdata

M = asu_get_var2vph_rotate_matrix(boxdata.lat_cen, boxdata.lon_cen)

szbox = size(boxdata.x_box)
xcen = (szbox[1]+1)/2d*boxdata.dx
ycen = (szbox[2]+1)/2d*boxdata.dy

return, {M:M, dx:boxdata.dx, xcen:xcen, dy:boxdata.dy, ycen:ycen, rsun:boxdata.rsun}

end
 