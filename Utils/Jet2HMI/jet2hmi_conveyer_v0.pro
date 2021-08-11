pro jet2hmi_conveyer_v0, id, filename, outfile, outpict, json_in = json_in, json_out = json_out, boxespath = boxespath, cachepath = cachepath, km = km, fov = fov, no_NLFFF = no_NLFFF

if n_elements(dll_location) eq 0 then dll_location = 's:\Projects\Physics104_291\ProgramD64\WWNLFFFReconstruction.dll'

if n_elements(km) eq 0 then km = 2000d
if n_elements(fov) eq 0 then fov = 500d ; arcsec

if n_elements(boxespath) eq 0 then boxespath = 'g:\BIGData\UData\SDOBoxes'
if n_elements(cachepath) eq 0 then cachepath = 'g:\BIGData\UCache\HMI'

jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds
if details eq !NULL then return

if n_elements(json_in) eq 0 then begin
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
    
    ; NB! check out of limb!
    x_arc = [0, fov[0]] + frame2work.crval1 - frame2work.crpix1*frame2work.cdelt1
    y_arc = [0, fov[1]] + frame2work.crval2 - frame2work.crpix2*frame2work.cdelt2
endif else begin
    openr, lun, json_in, /get_lun
    str = ""
    result = ""
    while not EOF(lun) do begin
        readf, lun, str
        result += str
    endwhile
    close, lun
    free_lun,lun
  
    jsonr = json_parse(result)
    
    xl = jsonr["x_arc"]
    x_arc = double(xl.ToArray()) 
    yl = jsonr["y_arc"]
    y_arc = double(yl.ToArray()) 
    fits_n = jsonr["fits_n"]
    for k = 0, n_elements(frames)-1 do begin
        if frames[k].fitsn+1 eq fits_n then begin
            ctrl_frame = k
            break
        endif  
    endfor
    frame2work = frames[ctrl_frame]
endelse

mfo_box_load, frame2work.time_obs, id, x_arc, y_arc, km, boxespath, cachepath $
            , box = box $
            , size_fov = size_fov $
            , /save_pbox $
            , /save_sst $
            , /no_sel_check $
            , no_NLFFF = no_NLFFF $
            , dll_location = dll_location $
            , NLFFF_filename = NLFFF_filename $
            , POT_filename = POT_filename $
            , BND_filename = BND_filename $
            , sun_graph = sun_graph $
            , pict_win = pict_win $
            , x_mag = x_mag, y_mag = y_mag, bmax = bmax $
            , /no_title_prefix

asu_box_get_coord, box, boxdata

jet = lonarr(size_fov[1], size_fov[2])
x0 = frame2work.crval1 - frame2work.crpix1*frame2work.cdelt1
y0 = frame2work.crval2 - frame2work.crpix2*frame2work.cdelt2
xstep = x_mag[1]-x_mag[0]
ystep = y_mag[1]-y_mag[0]
for k = frame2work.CoordPtr, frame2work.CoordPtr + frame2work.Card - 1 do begin
    px = fix((x0 + coords[0, k]*frame2work.cdelt1 - x_mag[0])/xstep)
    py = fix((y0 + coords[1, k]*frame2work.cdelt2 - y_mag[0])/ystep)
    if px lt 0 || px ge size_fov[1] || py lt 0 || py ge size_fov[2] then continue
    jet[px, py] = 1
endfor  

;rcont = contour(gauss_smooth(double(jet),3,/edge_truncate),x_mag,y_mag, min_value = 0, max_value = 0.3, n_levels = 1, overplot = sun_graph, color = 'crimson', c_thick = 3)
rcont = contour(gauss_smooth(double(jet),3,/edge_truncate),x_mag,y_mag, min_value = 0, max_value = 0.3, n_levels = 2, overplot = sun_graph, color = 'crimson', c_thick = 3)
;jimage = image(jet, x_mag, y_mag, OVERPLOT = sun_graph)
;jimage.transparency = 50

pict_win.Save, outpict, width = 1200, height = 700, bit_depth = 2
pict_win.Close

szbox = size(box.bx)
parameters = {x_arc:x_arc,      y_arc:y_arc,      fits_n:fits_n, id:id, filename:filename, km:km, size_box:szbox[1:3], size_fov:size_fov[1:2], ctrl_frame:ctrl_frame, bmax:fix(bmax)}
json =       {x_arc:fix(x_arc), y_arc:fix(y_arc), fits_n:fits_n, id:id, filename:filename, km:km, size_box:szbox[1:3], size_fov:size_fov[1:2], ctrl_frame:ctrl_frame, bmax:fix(bmax)}
            
save, filename = outfile, details, frames, coords, rotcrds, box, boxdata, parameters $
    , NLFFF_filename, POT_filename, BND_filename

asu_json_save_list, json, json_out
    
end
