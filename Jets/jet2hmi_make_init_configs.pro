pro jet2hmi_make_init_configs, from, to, objs, wave, fov

fov = double(fov)

file_mkdir, to

sources = file_search(filepath('*', root_dir = from))
foreach source, sources do begin
    f_inf = file_info(source)
    if ~f_inf.directory then continue
    obj_dir = source + path_sep() + objs
    f_inf = file_info(obj_dir)
    if ~f_inf.directory then continue
    sav_file = obj_dir + path_sep() + asu_compstr(wave) + '.sav'
    f_inf = file_info(sav_file)
    if ~f_inf.exists then continue
    
    jet2hmi_candidates2arrays, sav_file, details, frames, coords, rotcrds
    if details eq !NULL then continue
    
    maxcard = 0L;
    kmax = -1;
    for k = 0, n_elements(details)-1 do begin
        if details[k].MaxCard gt maxcard then begin
            maxcard = details[k].MaxCard
            kmax = k 
        endif
    endfor
    ctrl_frame = details[kmax].MaxCardFrame
    fits_n = frames[ctrl_frame].fitsn + 1
    frame2work = frames[ctrl_frame]
    
    pos = strpos(source, path_sep(), /REVERSE_SEARCH)
    id = strmid(source, pos+1)
    
    expr = stregex(id, '([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9]).*',/subexpr,/extract)
    if n_elements(expr) ne 4 then continue
    r_sun = asu_solar_radius(expr[1], expr[2], expr[3])
    
    x0 = frame2work.crval1 - frame2work.crpix1*frame2work.cdelt1
    y0 = frame2work.crval2 - frame2work.crpix2*frame2work.cdelt2
    xc = fov[0]/2 + x0
    yc = fov[1]/2 + y0
    xm = fov[0] + x0
    ym = fov[1] + y0
    dist = sqrt(xc^2 + yc^2)
    if dist gt r_sun-10 then continue

    if sqrt(x0^2 + y0^2) gt r_sun then continue
    if sqrt(x0^2 + ym^2) gt r_sun then continue
    if sqrt(xm^2 + y0^2) gt r_sun then continue
    if sqrt(xm^2 + ym^2) gt r_sun then continue
    
    x_arc = [0, fov[0]] + frame2work.crval1 - frame2work.crpix1*frame2work.cdelt1
    y_arc = [0, fov[1]] + frame2work.crval2 - frame2work.crpix2*frame2work.cdelt2

    json = {x_arc:fix(x_arc), y_arc:fix(y_arc), fits_n:fits_n, id:id, filename:sav_file}

    json_out = to + path_sep() + id + '.json'
    asu_json_save_list, json, json_out
endforeach

end
