function sdo_utils_download_cutout, item, config, ds, save_dir, segment = segment

ts = anytim(config.tstart)
te = anytim(config.tstop)
n_frames = (te-ts)/12

time = anytim(config.tstart, out_style = 'UTC_EXT')
Rctr = asu_solar_radius(time.year, time.month, time.day) - 15
Robs = sqrt(config.xc^2 + config.yc^2)
if Robs gt Rctr then begin
    config.xc *= Rctr/Robs 
    config.yc *= Rctr/Robs 
endif   

query = jsoc_get_query(ds, config.tstart, config.tstop, item, segment = segment, $
                       processing=processing, t_ref=config.tref, x=config.xc, y=config.yc,$
                       width=config.wpix, height=config.hpix)
message,"Requesting data from JSOC...",/info
urls = jsoc_get_urls(query, processing = processing, file_names = filenames)
msg = "got "+strcompress(n_elements(urls), /remove_all)+" URLs"
message,msg,/info

message,'downloading with aria2...',/info
aria2_urls_rand, urls, save_dir
message, 'download complete', /info

return, n_elements(urls)

end