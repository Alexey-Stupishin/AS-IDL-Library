pro l_sdo_utils_download_cutout_rot, rot_angle, x, y, xn, yn  
compile_opt idl2

cs = cos(rot_angle*!DTOR)
ss = sin(rot_angle*!DTOR)

xn =   x*cs + y*ss
yn = - x*ss + y*cs

end

function sdo_utils_download_cutout, item, config, ds, save_dir, segment = segment, no_tracking = no_tracking, transform = transform
compile_opt idl2

if n_elements(no_tracking) eq 0 then no_tracking = 0

ts = anytim(config.tstart)
te = anytim(config.tstop)
n_frames = (te-ts)/12

time = anytim(config.tstart, out_style = 'UTC_EXT')
Rsun = asu_solar_radius(time.year, time.month, time.day)
Rctr = Rsun - 15
Robs = sqrt(config.xc^2 + config.yc^2)
if Robs gt Rctr then begin
    config.xc *= Rctr/Robs
    config.yc *= Rctr/Robs
endif

x = config.xc
y = config.yc
width = config.wpix
height = config.hpix
transform = !NULL
if config.rot_angle ne 0 then begin
    left = config.xc - config.warc/2d; 
    right = config.xc + config.warc/2d;
    bottom = config.yc - config.harc/2d;
    top = config.yc + config.harc/2d;
    l_sdo_utils_download_cutout_rot, config.rot_angle, left, top, ltx, lty
    l_sdo_utils_download_cutout_rot, config.rot_angle, right, top, rtx, rty
    l_sdo_utils_download_cutout_rot, config.rot_angle, left, bottom, lbx, lby
    l_sdo_utils_download_cutout_rot, config.rot_angle, right, bottom, rbx, rby
    horz = minmax([ltx, rtx, lbx, rbx])
    vert = minmax([lty, rty, lby, rby])
    x = (horz[0]+horz[1])/2d
    warc = horz[1]-horz[0]
    width = round(warc/config.arcpix_aia)
    y = (vert[0]+vert[1])/2d
    harc = vert[1]-vert[0]
    height = round(harc/config.arcpix_aia)
    if config.rot_angle ge 0 then begin
        dleft = lby - vert[0]
        dright = rty - vert[0]
        dbottom = rbx - horz[0]
        dtop = ltx - horz[0]
    endif else begin
        dleft = lty - vert[0]
        dright = rby - vert[0]
        dbottom = lbx - horz[0]
        dtop = rtx - horz[0]
    endelse
    dleft /= config.arcpix_aia
    dright /= config.arcpix_aia
    dbottom /= config.arcpix_aia
    dtop /= config.arcpix_aia
    transform = {angle:config.rot_angle, dleft:dleft, dright:dright, dbottom:dbottom, dtop:dtop}
endif
    
query = jsoc_get_query_ex(ds, config.tstart, config.tstop, item, segment = segment $
                          , cadence = config.cadence $   
                          , processing=processing, t_ref=config.tref, x=x, y=y $
                          , width=width, height=height, no_tracking = no_tracking)
message,"Requesting data from JSOC...",/info
urls = jsoc_get_urls(query, processing = processing, file_names = filenames)
msg = "got "+strcompress(n_elements(urls), /remove_all)+" URLs"
message,msg,/info

message,'downloading with aria2...',/info
aria2_urls_rand, urls, save_dir
message, 'download complete', /info

return, n_elements(urls)

end