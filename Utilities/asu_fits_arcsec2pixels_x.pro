pro asu_fits_arcsec2pixels_x, arcs, ind, x, step = step

step = ind.CDELT1
 
x = (arcs - ind.CRVAL1)/ind.CDELT1 + ind.CRPIX1  

end
