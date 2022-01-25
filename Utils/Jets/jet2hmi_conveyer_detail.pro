pro jet2hmi_conveyer_detail, id, i, params, csvinfo, detail, frames, coords, outpath, pictpath, confpath $
                           , boxespath = boxespath, cachepath = cachepath

x_center = (csvinfo.x[0]+csvinfo.x[1])/2
y_center = (csvinfo.y[0]+csvinfo.y[1])/2
x_arc = x_center + [-params.init_fov/2, params.init_fov/2]
y_arc = y_center + [-params.init_fov/2, params.init_fov/2]
mfo_box_load, csvinfo.tmax, id, x_arc, y_arc, 2000, boxespath, cachepath $
            , box = box $
            , /no_sel_check $
            , /no_NLFFF $
            , size_fov = size_fov $
            , /winclose $
            , x_mag = x_mag, y_mag = y_mag, bmax = bmax, full_Bz = full_Bz $
            , /no_title_prefix

if bmax lt params.b_check then message, "Too small magnetic field"

res = jets2hmi_mag_fov(full_Bz.data, full_Bz.index, {x:x_center, y:y_center}, params, x_fov, y_fov)

if res eq 0 then message, "Find FOV problems"

x_fov[0] = min([x_fov[0], double(csvinfo.x[0])])
x_fov[1] = max([x_fov[1], double(csvinfo.x[1])])
y_fov[0] = min([y_fov[0], double(csvinfo.y[0])])
y_fov[1] = max([y_fov[1], double(csvinfo.y[1])])
mfo_box_load, csvinfo.tmax, id, x_fov, y_fov, 400, boxespath, cachepath $
            , box = box $
            , aia_euv = [171] $
            , /no_sel_check $
            , /no_NLFFF $
            , dx_maxsize = params.dx_maxsize $
            , size_fov = size_fov $
            , x_mag = x_mag, y_mag = y_mag, bmax = bmax $
            , sun_graph = sun_graph $
            , pict_win = pict_win $
            , /no_title_prefix

ctrl_frame = detail.MaxCardFrame
fits_n = frames[ctrl_frame].fitsn + 1
frame2work = frames[ctrl_frame]
x0 = frame2work.crval1 - frame2work.crpix1*frame2work.cdelt1
y0 = frame2work.crval2 - frame2work.crpix2*frame2work.cdelt2
xstep = x_mag[1]-x_mag[0]
ystep = y_mag[1]-y_mag[0]

jet = lonarr(size_fov[1], size_fov[2])
jetall = lonarr(size_fov[1], size_fov[2])
for fpos = detail.frameptr, detail.frameptr+detail.nframes-1  do begin
  frame2work = frames[fpos]
    for k = frame2work.CoordPtr, frame2work.CoordPtr + frame2work.Card - 1 do begin
        px = fix((x0 + coords[0, k]*frame2work.cdelt1 - x_mag[0])/xstep)
        py = fix((y0 + coords[1, k]*frame2work.cdelt2 - y_mag[0])/ystep)
        if px lt 0 || px ge size_fov[1] || py lt 0 || py ge size_fov[2] then continue
        jetall[px, py] = 1
        if fpos eq ctrl_frame then jet[px, py] = 1 
    endfor
endfor

rcont = contour(gauss_smooth(double(jet),3,/edge_truncate),x_mag,y_mag, min_value = 0, max_value = 0.3, n_levels = 2, overplot = sun_graph, color = 'crimson', c_thick = 3)
rcont = contour(gauss_smooth(double(jetall),3,/edge_truncate),x_mag,y_mag, min_value = 0, max_value = 0.3, n_levels = 2, overplot = sun_graph, color = 'yellow', c_thick = 3)

; ----- OUTPUT
id_ext = id + '_(' + asu_compstr(i+1) + ')'

; --------- picture
outpict = pictpath + path_sep() + id_ext + '.png'
pict_win.Save, outpict, width = 1200, height = 700, bit_depth = 2
pict_win.Close

; --------- json
szbox = size(box.bx)
json = {x_fov:x_fov, y_fov:y_fov, fits_n:fits_n, id:id, ndet:i+1, size_box:szbox[1:3], size_fov:size_fov[1:2], ctrl_frame:ctrl_frame, bmax:fix(bmax)}
outconf = confpath + path_sep() + id_ext + '.json'
asu_json_save_list, json, outconf

; --------- data
asu_box_get_coord, box, boxdata
outfile = outpath + path_sep() + id_ext + '.sav'
save, filename = outfile, detail, frames, coords, boxdata, json
    
end
