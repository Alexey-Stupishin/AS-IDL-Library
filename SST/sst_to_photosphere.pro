function sst_to_photosphere, date_obs, infile, scale, depth, i0 = i0, wcs0 = wcs0, wcsR = wcsR, dr = dr

    t0 = systime(/seconds)

    restore, infile

    ;ABSB    DOUBLE[1111, 621]
    ;AZIM    DOUBLE[1111, 621]
    ;INCL    DOUBLE[1111, 621]
    ;CDELT1  0.11799999999999999
    ;CDELT2  0.11799999999999999
    ;CRPIX1  556.00000000000000
    ;CRPIX2  311.00000000000000
    ;CRVAL1  94.762100000000004
    ;CRVAL2  -260.52600000000001

    sz = size(absB)
    naxis1 = sz[1]
    naxis2 = sz[2]

    data = dblarr(naxis1, naxis2, 3)
    data[*, *, 0] = absB
    data[*, *, 1] = incl
    data[*, *, 2] = azim

    foo = get_sun(date_obs, he_lon = crln_obs, he_lat = crlt_obs)

    i0 = {naxis:2, cdelt1:cdelt1, crval1:crval1, crpix1:crpix1, naxis1:naxis1, cdelt2:cdelt2, crval2:crval2, crpix2:crpix2, naxis2:naxis2, crlt_obs:crlt_obs, crln_obs:crln_obs, crota2:0, date_obs:date_obs $
        , wcsname:'Helioprojective-cartesian', ctype1:'HPLN-TAN', ctype2:'HPLN-TAN', cunit1:'arcsec', cunit2:'arcsec'}

    wcs0 = FITSHEAD2WCS( i0 )

    ;trying to correct position bug
    wcs2map, data[*,*,0], wcs0, map
    map2wcs, map, wcs0

    ;Calculating reference point in Carrington  coordinate system
    asu_solar_par, i0.date_obs, solar_r = solar_r
    center_arcsec  = ([(i0.naxis1+1)/2d, (i0.naxis2+1)/2d]-[i0.crpix1, i0.crpix2])*[i0.CDELT1, i0.CDELT2] + [i0.crval1, i0.crval2]
    wcs_convert_from_coord,wcs0,center_arcsec,'HG', lon, lat, /carrington

    step_in_R = i0.CDELT1/solar_r /scale
    dx_deg = step_in_R * 180d /!dpi
    dr = [step_in_R, step_in_R, step_in_R]

    ;Seting up the basemap projection as a WCS structure
    n1 = sst_to_box_ext(fix(i0.naxis1*scale), depth)
    n2 = sst_to_box_ext(fix(i0.naxis2*scale), depth)
    wcsR = WCS_2D_SIMULATE(n1, n2, cdelt = dx_deg, crval =[lon,lat],$
        type ='CR', projection = 'cea', date_obs = i0.date_obs)

    ;Converting field to spherical coordinates
    hmi_b2ptr, i0, data, bptr, lonlat=lonlat

    ; remapping data to the basmap projection
    bp = wcs_remap(bptr[*,*,0],wcs0, wcsR, /ssaa)
    bt = wcs_remap(bptr[*,*,1],wcs0, wcsR, /ssaa)
    br = wcs_remap(bptr[*,*,2],wcs0, wcsR, /ssaa)

    base = {bx:-bp, by:-bt, bz:br}

    message, 'prepare complete in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
    
    return, base
end
