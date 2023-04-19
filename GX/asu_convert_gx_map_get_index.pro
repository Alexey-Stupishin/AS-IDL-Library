pro asu_convert_gx_map_get_index, rmap, index
compile_opt idl2

sz = size(rmap.data)
crpix1 = rmap.xc/rmap.dx + (sz[1]-1)/2d 
crpix2 = rmap.yc/rmap.dy + (sz[2]-1)/2d

index = {NAXIS1:sz[1], NAXIS2:sz[2], CDELT1:rmap.dx, CDELT2:rmap.dy, CRPIX1:crpix1, CRPIX2:crpix2, CRVAL1:0, CRVAL2:0 $
       , XCEN:rmap.xc, YCEN:rmap.yc, R_SUN:rmap.rsun, DIRECTIONS:rmap.directions, DATE_OBS:rmap.time, ID:rmap.id, FREQ:rmap.freq} 

end
