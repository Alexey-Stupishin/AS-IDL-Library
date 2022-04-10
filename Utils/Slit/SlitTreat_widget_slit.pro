pro slittreat_widget_slit
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_get_timedist
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['straight'] eq !NULL then return

str = global['straight']
sz = size(str)

p0 = (sz[1]-1)/2
from = p0-global['slitwidth']+1
to   = p0+global['slitwidth']-1
slit = str[from:to, *, *]

if from eq to then begin
    showslit = total(slit, 1)
endif else begin
    case global['slitmode'] of
        'MODEMEAN': begin
            showslit = mean(slit, dimension = 1)
        end    
        'MODEMED': begin
            showslit = median(slit, dimension = 1)
        end        
        'MODEQ75': begin
            showslit = ass_slit_widget_get_percentil(slit, 0.75)
        end        
        'MODEQ95': begin
            showslit = ass_slit_widget_get_percentil(slit, 0.95)
        end
    endcase            
endelse    

pos = global['slitcontr']
thresh = global['slitbright']/100d

ms = max(showslit)
showslit /= ms

idxs = where(showslit gt thresh, count)
if count gt 0 then begin
    showslit[idxs] = thresh
    showslit /= thresh
endif    

contrv = double(pos)/100d
if contrv gt 0 then begin
    contr = contrv*29d + 1
endif else begin
    contr = 1d - abs(contrv)
endelse    
global['timedist'] = showslit^contr

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_slit_range, dt_min, total_Mm ; min, Mm  
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

sz = size(global['straight']) ; slit x length x frames
ind = global['data_ind']
ind0 = ind[0]
ind1 = ind[n_elements(ind)-1]
dt = anytim(ind1.date_obs) - anytim(ind0.date_obs)
dt_min = dt/60d
total_km = sz[2] * ind0.cdelt1 * 6.96d5/ind0.rsun_obs
total_Mm = total_km * 1d-3

end

;----------------------------------------------------------------------------------
function ass_slit_widget_slit_convert, xy, mode = mode 
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

slitsize = global['slitsize']

xmargpix = global['xmargin'] * !d.x_ch_size
ymargpix = global['ymargin'] * !d.y_ch_size

xplotpix = slitsize[0] - xmargpix[0] - xmargpix[1] 
yplotpix = slitsize[1] - ymargpix[0] - ymargpix[1] 

ass_slit_widget_slit_range, dt_min, total_Mm ; min, Mm

out = dblarr(2)
if n_elements(mode) gt 0 && mode eq 'win2dat' then begin
    out[0] = double(xy[0]-xmargpix[0])/double(xplotpix)*dt_min
    out[1] = double(xy[1]-ymargpix[0])/double(yplotpix)*total_Mm
endif else begin
    out[0] = double(xy[0])/dt_min*double(xplotpix) + xmargpix[0] 
    out[1] = double(xy[1])/total_Mm*double(yplotpix) + ymargpix[0] 
endelse    

return, out

end

;----------------------------------------------------------------------------------
function ass_slit_widget_get_speed, crd0, crd1

duration = (crd1[0] - crd0[0]) * 60d ; seconds in 1 hor pixel
pos_km = (crd1[1] - crd0[1]) * 1d3; km in 1 vert pixel
speed = pos_km / duration
if speed lt 100 then begin
    speed = round(speed)
endif else begin
    speed = round(speed / 10d) * 10
endelse

return, speed
          
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_show_slit
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

asw_control, 'SLIT', GET_VALUE = drawID
WSET, drawID
;!p.background = 'FFFFFF'x
device, decomposed = 0
loadct, 0, /silent

if global['timedist'] eq !NULL then begin
    asw_control, 'TDFROM', SET_VALUE = ''
    asw_control, 'TDTO', SET_VALUE = ''
    asw_control, 'TDLNG', SET_VALUE = ''
    asw_control, 'TDCOORDS', SET_VALUE = ''
    erase
    return
endif

pos = global['slitcontr']

td0 = transpose(global['timedist'], [1, 0])
sz = size(td0)

ass_slit_widget_slit_range, dt_min, total_Mm ; min, Mm

xrange = [0, dt_min]
x_arg = asu_linspace(0, xrange[1], sz[1])
yrange = [0, total_Mm]
y_arg = asu_linspace(0, yrange[1], sz[2])
tvplot, td0, x_arg, y_arg, xrange = xrange, yrange = yrange, xmargin = global['xmargin'], ymargin = global['ymargin'], xtitle = 'Time, min', ytitle = 'Distance, Mm'

p = global['currpos']/60d * global['cadence']

device, decomposed = 1
oplot, [p, p], [0, yrange[1]], color = 'FF0000'x, thick = 1.5

slist = global['speed_list']
for k = 0, slist.Count()-1 do begin
    crds = slist[k]
    crd0 = crds.first
    crd1 = crds.second
    oplot, [crd0[0], crd1[0]], [crd0[1], crd1[1]], color = '00FF00'x, thick = 1.5
    oplot, [crd0[0]], [crd0[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
    oplot, [crd1[0]], [crd1[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
    
    speed = ass_slit_widget_get_speed(crd0, crd1)
    sstr = strcompress(string(abs(speed), format = '(%"%5d")'), /remove_all) + ' km/s'

    align = speed gt 0 ? 1.0 : 0.0
    XYOUTS, (crd0[0]+crd1[0])/2, (crd0[1]+crd1[1])/2, sstr, color = '0000FF'x, alignment = align, charsize = 1.8, charthick = 1.5 
endfor

if global['speed_first_pt'] ne !NULL then begin
    crd0 = global['speed_first_pt']
    oplot, [crd0[0]], [crd0[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
endif

xy = global['approx']
sz = size(xy)
xy_from = xy[*, 0]
xy_to = xy[*, sz[2]-1]

ind = global['data_ind']
ind0 = ind[0]
ind1 = ind[n_elements(ind)-1]
xy0 = round(xy_from)
xy1 = round(xy_to)

asw_control, 'TDFROM', SET_VALUE = asu_extract_time(ind0.date_obs, out_style = 'asu_time_std')
asw_control, 'TDTO', SET_VALUE = asu_extract_time(ind1.date_obs, out_style = 'asu_time_std')
asw_control, 'TDCOORDS', SET_VALUE = string(xy0[0], xy0[1], xy1[0], xy1[1], FORMAT = '(%"(%d\x22, %d\x22)   -   (%d\x22, %d\x22)")') 

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_export_sav
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

timedist = global['timedist']
if timedist eq !NULL then return

path = ''
if pref.hasKey('expsav_path') then begin
    path = pref['expsav_path']
endif
file = dialog_pickfile(DEFAULT_EXTENSION = 'sav', FILTER = ['*.sav'], GET_PATH = path, PATH = path, file = global['proj_name'], /write, /OVERWRITE_PROMPT)
if file eq '' then return

first = global['data_ind', 0]
last = global['data_ind', -1]

szd = size(global['data_list'])

xy = global['approx']
sz = size(xy)
slit_crd_from = xy[*, 0]
slit_crd_to = xy[*, sz[2]-1]

slit_time_from = first.date_obs
slit_time_to = last.date_obs

half_width = global['slitwidth']
mode = global['slitmode']

sz = size(timedist)
ass_slit_widget_slit_range, dt_min, total_Mm
time_step = dt_min/(sz[2]-1)*60d
dist_step = total_Mm/(sz[1]-1)*1d3

jets = !NULL
slist = global['speed_list']
if slist.Count() gt 0 then begin
    jet = {speed_time_from:0d, speed_dist_from:0d, speed_time_to:0d, speed_dist_to:0d, speed:0d}
    jets = replicate(jet, slist.Count())
    for k = 0, slist.Count()-1 do begin
        crds = slist[k]
        crd0 = crds.first
        crd1 = crds.second
        jets[k].speed = ass_slit_widget_get_speed(crd0, crd1)
        jets[k].speed_time_from = crd0[0]*60d
        jets[k].speed_dist_from = crd0[1]*1d3
        jets[k].speed_time_to = crd1[0]*60d
        jets[k].speed_dist_to = crd1[1]*1d3
    end
endif

save, filename = file, timedist, slit_crd_from, slit_crd_to, slit_time_from, slit_time_to, dist_step, time_step, half_width, mode, jets

pref['expsav_path'] = path
save, filename = pref['pref_path'], pref

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_export
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

fname = 'TD-' + global['proj_name']
file = dialog_pickfile(DEFAULT_EXTENSION = 'png', FILTER = ['*.png'], GET_PATH = path, PATH = pref['export_path'], file = fname, /write, /OVERWRITE_PROMPT)
if file eq '' then return

WIDGET_CONTROL, /HOURGLASS

asw_control, 'SLIT', GET_VALUE = drawID
WSET, drawID
write_png, file, tvrd(true=1)
pref['export_path'] = path
save, filename = pref['pref_path'], pref

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_update_td

common G_ASS_SLIT_WIDGET, global

asm_bezier_norm_vs_points, norm_poly, global['reper_pts'], 1
global['norm_poly'] = norm_poly

ind0 = global['data_ind', 0]

step1 = ind0.cdelt1
markup = asm_bezier_markup_curve_eqv(norm_poly, [0, 1], step1)
global['markup'] = markup

step2 = step1
hwidth = global['maxslitwidth']
grids = asm_bezier_markup_normals(norm_poly, markup[2, *], step2, hwidth) ; returns {x_grid:x_grid, y_grid:y_grid}
global['grids'] = grids

straight = ass_slit_data2grid(global['data_list'], grids, ind0)
global['straight'] = straight

ass_slit_widget_show_image
ass_slit_widget_get_timedist
ass_slit_widget_show_slit

end
