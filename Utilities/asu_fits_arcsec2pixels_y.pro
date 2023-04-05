pro asu_fits_arcsec2pixels_y, arcs, ind, y, step = step

step = ind.CDELT2
 
y = (arcs - ind.CRVAL2)/ind.CDELT2 + ind.CRPIX2  

end
