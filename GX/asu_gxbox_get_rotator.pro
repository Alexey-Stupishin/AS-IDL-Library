function asu_gxbox_get_rotator, boxdata
compile_opt idl2

M = asu_get_var2vph_rotate_matrix(boxdata.lat_cen, boxdata.lon_cen)
asu_get_direction_cosine, boxdata.lat_cen, boxdata.lon_cen, dircos

szbox = size(boxdata.x_box)
xcen = (szbox[1]+1)/2d*boxdata.dx
ycen = (szbox[2]+1)/2d*boxdata.dy

return, {M:M, dx:boxdata.dx, xcen:xcen, dy:boxdata.dy, ycen:ycen, visxcen:boxdata.x_cen, visycen:boxdata.y_cen, rsun:boxdata.rsun, dircos:dircos}

end
 