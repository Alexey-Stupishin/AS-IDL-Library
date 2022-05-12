pro mfo_box_load_base, obstime, prefix, x_arc, y_arc, dx_km, out_dir, tmp_dir $
                , dx_maxsize = dx_maxsize, dx_kmc = dx_kmc, centre = centre $
                , box = box, save_pbox = save_pbox, pbox = pbox $
                , hmi_files = hmi_files, hmi_dir = hmi_dir $
                , aia_uv = aia_uv, aia_euv = aia_euv $
                , magnetogram = magnetogram, full_Bz = full_Bz, hmi_prep = hmi_prep

    setenv, 'WCS_RSUN=6.96d8'
    arc_RSun = 960d ; RSun in arcsec, approximately
    arc_km_approx = 6.96d5/arc_RSun ; km in arcsec, approximately
      
    file_mkdir, out_dir
    file_mkdir, tmp_dir
      
    centre = dblarr(2)
    centre[0] = double((x_arc[0]+x_arc[1])/2.); 
    centre[1] = double((y_arc[0]+y_arc[1])/2.);
    Rcen = centre/arc_RSun
    lat = asin(Rcen[1])
    lon = asin(Rcen[0]/sqrt(1-Rcen[1]^2))
    sclat = cos(lat)
    sclon = cos(lat)*cos(lon)
     
    size_arc = dblarr(2)
    size_arc[0] = double(x_arc[1]-x_arc[0])/sclat
    size_arc[1] = double(y_arc[1]-y_arc[0])/sclon
    
    dx_kmc = double(dx_km)  
    if keyword_set(dx_maxsize) then begin 
        dx_kmm = floor(double(max(size_arc*arc_km_approx/dx_maxsize))/100d)*100d
        if dx_kmm gt dx_kmc then dx_kmc = dx_kmm 
    endif    
    d_arc = dx_kmc / arc_km_approx
    
    size_pix = lonarr(3)
    size_pix[0] = ceil(size_arc[0]/d_arc)
    size_pix[1] = ceil(size_arc[1]/d_arc)
    size_pix[2] = double(floor(max(size_pix[0:1])*0.7))
    
    print, '***** dx_km = ' + asu_compstr(dx_kmc) + ', box = ' + asu_compstr(size_pix[0]) + ' x ' + asu_compstr(size_pix[1]) + ' x ' + asu_compstr(size_pix[2])
     
    gx_box_prepare_box_as, obstime, centre, size_pix, dx_kmc, out_dir = out_dir, tmp_dir = tmp_dir $
                         , box = box, make_pbox = save_pbox, pbox = pbox $
                         , hmi_files = hmi_files, hmi_dir = hmi_dir $
                         , aia_uv = aia_uv, aia_euv = aia_euv $
                         , magnetogram = magnetogram, full_Bz = full_Bz, hmi_prep = hmi_prep

end
