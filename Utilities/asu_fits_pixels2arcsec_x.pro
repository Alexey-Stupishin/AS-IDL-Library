pro asu_fits_pixels2arcsec_x, x, ind, arcs, step = step

step = ind.CDELT1
 
arcs = (x - ind.CRPIX1)*ind.CDELT1 + ind.CRVAL1 

end