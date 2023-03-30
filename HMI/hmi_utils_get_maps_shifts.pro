pro hmi_utils_get_maps_shifts, ind1, data1, ind2, data2, xrange, yrange, shifts_corr, shifts_rot, verbose = verbose, latitude = latitude, longitude = longitude

dsec = asu_diff_anytime(ind1.DATE_OBS, ind2.DATE_OBS, /sec)
shifts_corr = gx_align_image(data1(xrange[0]:xrange[1], yrange[0]:yrange[1]), data2(xrange[0]:xrange[1], yrange[0]:yrange[1]))
if n_elements(verbose) ne 0 then print, shifts_corr

asu_solar_par, ind1.DATE_OBS, solar_p = solar_p, solar_b = solar_b, solar_r = solar_r, sol_dec = sol_dec

pixcenx = (xrange[0]+xrange[1])*0.5d
arccenx = (pixcenx-ind1.CRPIX1)*ind1.CDELT1 + ind1.CRVAL1
pixceny = (yrange[0]+yrange[1])*0.5d
arcceny = (pixceny-ind1.CRPIX2)*ind1.CDELT2 + ind1.CRVAL2

rc = asu_sun_diff_rotation(arccenx, arcceny, dsec, solar_b, solar_r, x_new, y_new, latitude = latitude, longitude = longitude)
shifts_rot = [x_new-arccenx, y_new-arcceny]/[ind1.CDELT1, ind1.CDELT2]
if n_elements(verbose) ne 0 then print, shifts_rot

end
