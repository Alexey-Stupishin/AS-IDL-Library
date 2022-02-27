;----------------------------------------------------------------------------------
function ass_slit_widget_in_scope, xy, xycorr = xycorr
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

xycorr = xy

if global['data_list'] eq !NULL then return, 0

sz = size(global['data_list'])
xycorr[0] = 0 > xy[0] < (sz[1]-1)
xycorr[1] = 0 > xy[1] < (sz[2]-1)

return, xycorr[0] eq xy[0] && xycorr[1] eq xy[1]

end

;----------------------------------------------------------------------------------
function ass_slit_widget_convert, xy, mode = mode
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if n_elements(mode) gt 0 && mode eq 'win2dat' then begin
    return, (xy - global['data_shift'])*global['coef']
endif else begin
    return, xy/global['coef'] + global['data_shift']
endelse    
    
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_get_timedist
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['straight'] eq !NULL then return

str = global['straight']
sz = size(str)

p0 = (sz[1]+1)/2
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
sz = size(global['straight']) ; slit x length x frames

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

if global['timedist'] eq !NULL then begin
    asw_control, 'TDFROM', SET_VALUE = ''
    asw_control, 'TDTO', SET_VALUE = ''
    asw_control, 'TDLNG', SET_VALUE = ''
    asw_control, 'TDCOORDS', SET_VALUE = ''
    return
endif

pos = global['slitcontr']

td0 = transpose(global['timedist'], [1, 0])
sz = size(td0)

ass_slit_widget_slit_range, dt_min, total_Mm ; min, Mm

asw_control, 'SLIT', GET_VALUE = drawID
WSET, drawID
;!p.background = 'FFFFFF'x
device, decomposed = 0
loadct, 0, /silent

xrange = [0, dt_min]
x_arg = asu_linspace(0, xrange[1], sz[1])
yrange = [0, total_Mm]
y_arg = asu_linspace(0, yrange[1], sz[2])
tvplot, td0, x_arg, y_arg, xrange = xrange, yrange = yrange, xmargin = [10, 1], ymargin = [5, 1], xtitle = 'Time, min', ytitle = 'Distance, Mm'

p = global['currpos']/60d * global['cadence']

device, decomposed = 1
oplot, [p, p], [0, yrange[1]], color = 'FF0000'x, thick = 1.5

;scales = widget_info(asw_getctrl('TDSCALES'), /BUTTON_SET)
;if scales then begin
;    if total_km lt 1d4 then begin
;        y_km = 1d3/total_km *(sz[2]-1) ; Mm
;        kmstr = ' 1 Mm'
;    endif else begin
;        y_km = 1d4/total_km *(sz[2]-1) ; Mm
;        kmstr = ' 10 Mm'
;    endelse    
;    y_km = 1d4/total_km *(sz[2]-1) ; tens of Mm
;    oplot, [0, 0], [0, y_km], color = '0000FF'x, thick = 6
;    XYOUTS, 0, y_km, kmstr, color = '0000FF'x, alignment = 0d, charsize = 1.8, charthick = 1.5 
;    oplot, [0, 5], [0, 0], color = '0000FF'x, thick = 6
;    XYOUTS, sz[2]/50d, 5, '1 min', color = '0000FF'x, alignment = 1d, charsize = 1.8, charthick = 1.5 
;endif

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
xy0 = round((xy_from - ([ind0.naxis1, ind0.naxis2]-1d)*0.5d)*[ind0.cdelt1, ind0.cdelt2] + [ind0.xcen, ind0.ycen])
xy1 = round((xy_to - ([ind0.naxis1, ind0.naxis2]-1d)*0.5d)*[ind0.cdelt1, ind0.cdelt2] + [ind0.xcen, ind0.ycen])

asw_control, 'TDFROM', SET_VALUE = asu_extract_time(ind0.date_obs, out_style = 'asu_time_std')
asw_control, 'TDTO', SET_VALUE = asu_extract_time(ind1.date_obs, out_style = 'asu_time_std')
asw_control, 'TDCOORDS', SET_VALUE = string(xy0[0], xy0[1], xy1[0], xy1[1], FORMAT = '(%"(%d\x22, %d\x22)   -   (%d\x22, %d\x22)")') 

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_show_image, mode = mode, drag = drag
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['data_list'] eq !NULL then return
sz = size(global['data_list'])

if n_elements(drag) eq 0 then drag = 0

if global['xy_rt_dat'] eq !NULL && (n_elements(mode) gt 0 && mode eq 'SELWIN') then mode = 'FITWIN'

winsize = global['winsize']
if global['byte_list'] eq !NULL || (n_elements(mode) gt 0 && (mode eq 'MAKESELECT' || global['drawmode'] ne mode)) then begin
    if n_elements(mode) gt 0 && mode eq 'MAKESELECT' then mode = 'SELWIN'
    global['drawmode'] = mode
    global['byte_info'] = lonarr(sz[3])
    global['byte_list'] = dblarr(winsize[0], winsize[1], sz[3])
    case mode of
        'ACTSIZE': begin
            corn = long((winsize-sz[1:2])/2d)
            global['data_shift'] = corn
            global['coef'] = 1d
            for d = 0, 1 do begin
                if corn[d] ge 0 then begin
                    global['dat_range', d, 0] = 0
                    global['dat_range', d, 1] = sz[d+1]-1
                    global['win_range', d, 0] = corn[d]
                    global['win_range', d, 1] = sz[d+1]-1 + corn[d]
                endif else begin
                    global['dat_range', d, 0] = -corn[d]
                    global['dat_range', d, 1] = winsize[d]-1 - corn[d]
                    global['win_range', d, 0] = 0
                    global['win_range', d, 1] = winsize[d]-1
                endelse    
             endfor   
        end
            
        'FITWIN': begin
            global['coef'] = asu_get_scale_keep_ratio(global['winsize'], [0, 0], sz[1:2]-1, newsize)
            global['data_shift'] = lonarr(2)
            global['newsize'] = newsize
            delta = round((winsize-newsize)/2d)
            for d = 0, 1 do begin
                global['dat_range', d, 0] = 0
                global['dat_range', d, 1] = sz[d+1]-1
                global['win_range', d, 0] = delta[d]
                global['win_range', d, 1] = newsize[d]-1 + delta[d]
            endfor
        end
        
        'SELWIN': begin
            xy_lb_dat = global['xy_lb_dat']
            xy_rt_dat = global['xy_rt_dat']
            global['coef'] = asu_get_scale_keep_ratio(global['winsize'], xy_lb_dat, xy_rt_dat, newsize)
            global['newsize'] = newsize
            global['dat_range', 0, 0] = xy_lb_dat[0]
            global['dat_range', 0, 1] = xy_rt_dat[0]
            global['dat_range', 1, 0] = xy_lb_dat[1]
            global['dat_range', 1, 1] = xy_rt_dat[1]
            delta = round((winsize-newsize)/2d)
            for d = 0, 1 do begin
                global['win_range', d, 0] = delta[d]
                global['win_range', d, 1] = newsize[d]-1 + delta[d]
            endfor
            global['data_shift'] = [global['win_range', 0, 0] - round(xy_lb_dat[0]/global['coef']), global['win_range', 1, 0] - round(xy_lb_dat[1]/global['coef'])]
        end    
    endcase
endif 

p = global['currpos']
if global['byte_info', p] eq 0 || ~drag then begin
    base = dblarr(winsize[0], winsize[1])
    dat_range = global['dat_range']
    if global['drawmode'] eq 'ACTSIZE' then begin
        res = global['data_list', dat_range[0, 0]:dat_range[0, 1], dat_range[1, 0]:dat_range[1, 1], p]
    endif else begin
        newsize = global['newsize']
        coef = global['coef']
        res = bilinear(global['data_list', dat_range[0, 0]:dat_range[0, 1], dat_range[1, 0]:dat_range[1, 1], p], indgen(newsize[0])*coef, indgen(newsize[1])*coef)
    endelse
    win_range = global['win_range']
    base[win_range[0, 0]:win_range[0, 1], win_range[1, 0]:win_range[1, 1]] = res    
    global['byte_list', *, *, p] = bytscl(base)
    global['byte_info', p] = 1
end

asw_control, 'IMAGE', GET_VALUE = drawID
WSET, drawID
device, decomposed = 0
loadct, 0, /silent
;aia_lct_silent,wave = 171,/load
winsize = global['winsize']
plot, indgen(winsize[0]), indgen(winsize[1]), xmargin = [0, 0], ymargin = [0, 0], /nodata
;if drag || global['animation'] then begin
    tv, global['byte_list', *, *, p]
;endif else begin
;    implot, base, xmargin = [0, 0], ymargin = [0, 0], xmajor = 0, xminor = 0, ymajor = 0, yminor = 0
;endelse        

;wait, 0.1

hideall = widget_info(asw_getctrl('HIDEALL'), /BUTTON_SET)
hidemark = widget_info(asw_getctrl('HIDEAPPR'), /BUTTON_SET)
editappr = widget_info(asw_getctrl('EDITAPPR'), /BUTTON_SET)

if hideall && ~editappr then return

device, decomposed = 1

if ~hidemark && ~editappr && global['points'].Count() gt 0 then begin
    for k = 0, global['points'].Count()-1 do begin
        x = (global['points'])[k].x 
        y = (global['points'])[k].y 
        xy = ass_slit_widget_convert([x, y], mode = 'dat2win')
        oplot, [xy[0]], [xy[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
    endfor    
endif

if global['approx'] ne !NULL then begin
    xy = global['approx']
    sz = size(xy)
    for k = 0, sz[2]-1 do begin
        xy[*, k] = ass_slit_widget_convert(xy[*, k], mode = 'dat2win')
    endfor    
    oplot, xy[0, *], xy[1, *], thick = 1.5, color = 'FF00FF'x
endif

if global['appredit'] && global['reper_pts'] ne !NULL then begin
    xy0 = global['reper_pts']
    xy = ass_slit_widget_convert(xy0[*, 0], mode = 'dat2win')
    oplot, [xy[0]], [xy[1]], psym = 6, symsize = 2, thick = 1.5, color = 'FF0000'x
    for k = 1, 3 do begin
        xyp = xy
        xy = ass_slit_widget_convert(xy0[*, k], mode = 'dat2win')
        oplot, [xy[0]], [xy[1]], psym = 6, symsize = 2, thick = 2, color = 'FF0000'x
        oplot, [xyp[0], xy[0]], [xyp[1], xy[1]], thick = 1.5, color = 'FF0000'x
    endfor
endif


end

;----------------------------------------------------------------------------------
pro ass_slit_widget_clear_appr
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

global['approx'] = !NULL
global['markup'] = !NULL
global['grids'] = !NULL
global['straight'] = !NULL
global['speed_first_pt'] = !NULL
global['speed_list'] = list()
global['timedist'] = !NULL
global['reper_pts'] = !NULL
asw_control, 'SLIT', GET_VALUE = drawID
asw_control, 'EDITAPPR', SET_BUTTON = 0
WSET, drawID
erase
ass_slit_widget_show_image

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_save_as, save_proj = save_proj
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

WIDGET_CONTROL, /HOURGLASS

file = ''
if n_elements(save_proj) gt 0 && file_test(pref['proj_file']) then begin
    file = pref['proj_file']
endif else begin
    asw_control, 'FROMFILETEXT', GET_VALUE = str
    expr = stregex(str, '.*([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]).*',/subexpr,/extract)
    global['proj_name'] = expr[1]
    file = dialog_pickfile(DEFAULT_EXTENSION = 'spr', FILTER = ['*.spr'], GET_PATH = path, PATH = pref['proj_path'], file = expr[1], /write, /OVERWRITE_PROMPT)
    if file ne '' then begin
        pref['proj_path'] = path
        pref['proj_file'] = file
        save, filename = pref['pref_path'], pref 
    endif
endelse

save, filename = file, global
    
global['modified'] = 0
ass_slit_widget_set_ctrl
        
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_load, last_proj = last_proj
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

WIDGET_CONTROL, /HOURGLASS

file = ''
if n_elements(last_proj) gt 0 && file_test(pref['proj_file']) then begin
    file = pref['proj_file']
endif else begin
    file = dialog_pickfile(DEFAULT_EXTENSION = 'spr', FILTER = ['*.spr'], GET_PATH = path, PATH = pref['proj_path'], file = pref['proj_file'], /read, /must_exist)
    if file ne '' then begin
        pref['proj_path'] = path
        pref['proj_file'] = file
        save, filename = pref['pref_path'], pref
    endif    
endelse

if file eq '' then return

restore, file

ass_slit_widget_add_keys

global['modified'] = 0
global['animation'] = 0
global['appredit'] = 0
ass_slit_widget_set_ctrl
asw_control, 'HIDEAPPR', SET_BUTTON = 0
asw_control, 'HIDEALL', SET_BUTTON = 0
asw_control, 'EDITAPPR', SET_BUTTON = 0

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

xy = global['approx']
szd = size(global['data_list'])

slit_crd_from = dblarr(2)
slit_crd_from[0] = first.xcen + first.cdelt1*(xy[0,0] - (szd[1]-1d)/2d)
slit_crd_from[1] = first.ycen + first.cdelt2*(xy[1,0] - (szd[2]-1d)/2d)
slit_crd_to = dblarr(2)
slit_crd_to[0] = last.xcen + last.cdelt1*(xy[0,-1] - (szd[1]-1d)/2d)
slit_crd_to[1] = last.ycen + last.cdelt2*(xy[1,-1] - (szd[2]-1d)/2d)

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
pro ass_slit_widget_export_image
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

ind = global['data_ind', global['currpos']]
expr = stregex(ind.date_obs, '.*T([0-9][0-9]):([0-9][0-9]):([0-9][0-9]).*',/subexpr,/extract)
fname = 'Image-' + global['proj_name'] + '-' + expr[1] + expr[2] + expr[3]
file = dialog_pickfile(DEFAULT_EXTENSION = 'png', FILTER = ['*.png'], GET_PATH = path, PATH = pref['export_path'], file = fname, /write, /OVERWRITE_PROMPT)
if file eq '' then return

WIDGET_CONTROL, /HOURGLASS

asw_control, 'IMAGE', GET_VALUE = drawID
WSET, drawID
write_png, file, tvrd(true=1)
pref['export_path'] = path
save, filename = pref['pref_path'], pref

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_set_ctrl
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if global['proj_name'] ne '' then asw_control, 'SLITTREAT', BASE_SET_TITLE = 'SlitTreat - ' + global['proj_name']

asw_control, 'FROMFILETEXT', SET_VALUE = global['fromfile']
asw_control, 'TOFILETEXT', SET_VALUE = global['tofile']
asw_control, global['drawmode'], SET_BUTTON = 1
asw_control, 'ORDER', SET_DROPLIST_SELECT = ass_slit_widget_fit_orders(idx = global['fit_order'], mode = 'index')
sz = size(global['data_list'])
asw_control, 'SLIDER', SET_SLIDER_MIN = 1
asw_control, 'SLIDER', SET_SLIDER_MAX = sz[3]
asw_control, 'SLIDER', SET_VALUE = global['currpos'] + 1
asw_control, 'FRATE', SET_VALUE = round(global['framerate'])

ind = global['data_ind', global['currpos']]
asw_control, 'FRAMEDATE', SET_VALUE = asu_extract_time(ind.date_obs, out_style = 'asu_time_std')

asw_control, 'SLITWIDTH', SET_VALUE = global['slitwidth']
asw_control, global['slitmode'], SET_BUTTON = 1

asw_control, 'EDITAPPR', SET_BUTTON = 0

asw_control, 'SLITCONTR', SET_VALUE = global['slitcontr']
asw_control, 'SLITBRIGHT', SET_VALUE = global['slitbright']

ass_slit_widget_show_image
ass_slit_widget_get_timedist
ass_slit_widget_show_slit

end

;----------------------------------------------------------------------------------
function ass_slit_widget_need_save
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['data_list'] ne !NULL && global['modified'] then begin
    result = DIALOG_MESSAGE('All results will be lost! Exit anyway?', title = 'SlitTreat', /QUESTION)
    return, result eq 'Yes' ? 0 : 1
endif else begin
    return, 0
endelse    

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_update_td

common G_ASS_SLIT_WIDGET, global

asm_bezier_norm_vs_points, norm_poly, global['reper_pts'], 1
global['norm_poly'] = norm_poly

step1 = 1d
markup = asm_bezier_markup_curve_eqv(norm_poly, [0, 1], step1)
global['markup'] = markup

step2 = 1d
hwidth = global['maxslitwidth']
grids = asm_bezier_markup_normals(norm_poly, markup[2, *], step2, hwidth) ; returns {x_grid:x_grid, y_grid:y_grid}
global['grids'] = grids

straight = ass_slit_data2grid(global['data_list'], grids)
global['straight'] = straight

ass_slit_widget_show_image
ass_slit_widget_get_timedist
ass_slit_widget_show_slit

end
        
;----------------------------------------------------------------------------------
pro ass_slit_widget_buttons_event, event
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if (tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST') then begin
    if ~ass_slit_widget_need_save() then widget_control, event.top, /destroy
    return
endif

if TAG_NAMES(event, /STRUCTURE_NAME) eq  'WIDGET_TIMER' then begin
    eventval = 'TIMER'
endif else begin
    WIDGET_CONTROL, event.id, GET_UVALUE = eventval
endelse         

global['modified'] = 1

case eventval of
    'SLIT' : begin
        if event.type eq 0 then begin
            case event.press of
                1: begin
                    if global['speed_first_pt'] eq !NULL then begin
                        global['speed_first_pt'] = ass_slit_widget_slit_convert([event.x, event.y], mode = 'win2dat')
                    endif else begin
                        global['speed_list'].Add, {first:global['speed_first_pt'], second:ass_slit_widget_slit_convert([event.x, event.y], mode = 'win2dat')}
                        global['speed_first_pt'] = !NULL
                    endelse    
                    ass_slit_widget_show_slit
                end
                
                4: begin ; undo
                    if global['speed_first_pt'] eq !NULL && global['speed_list'].Count() gt 0 then begin
                        global['speed_first_pt'] = (global['speed_list'])[global['speed_list'].Count()-1].first
                        global['speed_list'].Remove
                    endif else begin
                        global['speed_first_pt'] = !NULL
                    endelse    
                    ass_slit_widget_show_slit
                end        
                
                else: begin
                end        
            endcase    
        endif    
    end
    
    'IMAGE' : begin
        if global['data_list'] eq !NULL then return
        sname = TAG_NAMES(event, /STRUCTURE_NAME)
;        case sname of
;            'WIDGET_DRAW': print, 'Draw, Type=' + string(event.type) + ' Press=' + string(event.press*1L) + ' Release=' + string(event.release*1L) + ' x=' + string(event.x) + ' y=' + string(event.y) $
;                                + ' Clicks=' + string(event.clicks) + ' Mod=' + string(event.modifiers) + ' Key=' + string(event.key)
;        endcase
        asw_control, 'HIDEAPPR', SET_BUTTON = 0
        asw_control, 'HIDEALL', SET_BUTTON = 0
        if global['appredit'] then begin
            case event.type of
                0: begin ; capture point
                    xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
                    dists = dblarr(4)
                    for k = 0, 3 do begin
                        dists[k] = (xy[0] - global['reper_pts', 0, k])^2 + (xy[1] - global['reper_pts', 1, k])^2 
                    endfor
                    dm = min(dists, im)
                    if dm lt 400 then begin
                        ;print, 'Capture point: ' + string(im) + ' xy = [' + string(event.x) + ',' + string(event.y) + '], d = ' + string(sqrt(dm))
                        global['pt_to_drag'] = im
                        WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 1
                    endif
                end
                
                1: begin
                    WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 0
                    xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
                    global['pt_to_drag'] = -1
                    global['approx'] = asm_bezier_create_line(global['reper_pts'], points = 1000) 
                    ;print, 'Finish capture: xy = [' + string(event.x) + ',' + string(event.y) + ']'
                    ass_slit_widget_update_td
                end
                
                2: begin
                    if global['pt_to_drag'] lt 0 then return
                    xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
                    global['reper_pts', 0, global['pt_to_drag']] = xy[0]
                    global['reper_pts', 1, global['pt_to_drag']] = xy[1]
                    global['approx'] = asm_bezier_create_line(global['reper_pts'], points = 100) 
                    ;print, 'Drag capture: xy = [' + string(event.x) + ',' + string(event.y) + ']'
                    ass_slit_widget_show_image
                end
            endcase    
            return
        endif    
        if event.type eq 0 and event.modifiers eq 2 then begin ; start selection
            xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
            if ~ass_slit_widget_in_scope(xy) then return
            WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 1
            global['xr'] = event.x
            global['yr'] = event.y
            global['select'] = 1
            ;print, string(event.x) + ', ' + string(event.y)
        endif else begin
            case event.type of
                0: begin
                    case event.press of
                        1: begin ; click point
                            xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
                            if ~ass_slit_widget_in_scope(xy) then return
                            global['points'].Add, {x:xy[0], y:xy[1]}
                        end
                        
                        4: begin ; undo click point
                            if global['points'].Count() gt 0 then begin
                                global['points'].Remove
                            endif    
                        end        
                        
                        else: begin
                        end        
                    endcase    
                    ass_slit_widget_show_image
                end

                1: begin
                    WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 0 ; release button
                    if global['select'] eq 1 then begin ; release selection
                        xx = minmax([global['xr'], event.x])
                        yy = minmax([global['yr'], event.y])
                        xy_lb_dat_t = long(ass_slit_widget_convert([xx[0], yy[0]], mode = 'win2dat'))
                        in_scope = ass_slit_widget_in_scope(xy_lb_dat_t, xycorr = xy_lb_dat)
                        xy_rt_dat_t = long(ass_slit_widget_convert([xx[1], yy[1]], mode = 'win2dat'))
                        in_scope = ass_slit_widget_in_scope(xy_rt_dat_t, xycorr = xy_rt_dat)
                        global['xy_lb_dat'] = xy_lb_dat
                        global['xy_rt_dat'] = xy_rt_dat
                        asw_control, 'SELWIN', SET_BUTTON = 1
                        ass_slit_widget_show_image, mode = 'MAKESELECT'
                    end    
                    global['select'] = 0
                end
                
                else: begin
                end        
            endcase  
        endelse            
        if event.type eq 2 then begin
            ass_slit_widget_show_image, /drag
            device, decomposed = 1
            rcolor = 150
            rthick = 2
            xr = global['xr']
            yr = global['yr']
            oplot, [xr, xr], [yr, event.y], color = rcolor, thick = rthick
            oplot, [event.x, event.x], [yr, event.y], color = rcolor, thick = rthick
            oplot, [xr, event.x], [yr, yr], color = rcolor, thick = rthick
            oplot, [xr, event.x], [event.y, event.y], color = rcolor, thick = rthick
            ;print, string(xr) + '-' + string(event.x) + ', ' + string(yr) + '-' + string(event.y)
        endif    
    end
        
    'SLIDER' : begin
        if global['data_list'] eq !NULL then return
        
        asw_control, 'SLIDER', GET_VALUE = pos
        global['currpos'] = pos-1
        ind = global['data_ind', global['currpos']]
        asw_control, 'FRAMEDATE', SET_VALUE = ind.date_obs
        ass_slit_widget_show_image
        ass_slit_widget_show_slit
    end
        
    'ACTSIZE' : begin
        ass_slit_widget_show_image, mode = 'ACTSIZE' 
    end
    'FITWIN' : begin
        ass_slit_widget_show_image, mode = 'FITWIN'
    end
    'SELWIN' : begin
        ass_slit_widget_show_image, mode = 'SELWIN'
    end
        
    'PROCEED' : begin
        ;if ass_slit_widget_need_save() then return 
        WIDGET_CONTROL, /HOURGLASS
        global['data_list'] = asu_get_file_sequence_data(pref['path'], global['fromfile'], global['tofile'], ind = ind, err = err)
        global['data_ind'] = ind 
        case err of
            1: result = DIALOG_MESSAGE('Please select both first and last files!', title = 'SlitTreat Error', /ERROR)
            2: result = DIALOG_MESSAGE('Not enough files found!', title = 'SlitTreat Error', /ERROR)
            else: begin
                sz = size(global['data_list'])
                global['cadence'] = (anytim(ind[sz[3]-1].date_obs) - anytim(ind[0].date_obs)) / (sz[3]-1)
                global['currpos'] = 0
                global['byte_list'] = !NULL
                global['slit_list'] = !NULL
                asw_control, 'FITWIN', SET_BUTTON = 1
                ass_slit_widget_show_image, mode = 'FITWIN'
                asw_control, 'SLIDER', SET_SLIDER_MIN = 1
                asw_control, 'SLIDER', SET_SLIDER_MAX = sz[3]
                asw_control, 'SLIDER', SET_VALUE = global['currpos'] + 1
                pref['proj_file'] = ''                
            endelse    
        endcase    
    end

    'FILEFROM' : begin
        ;if ass_slit_widget_need_save() then return 
        file = dialog_pickfile(DEFAULT_EXTENSION = 'fits', FILTER = ['*.fits'], GET_PATH = path, PATH = pref['path'])
        if file ne '' then begin
            pref['path'] = path
            save, filename = pref['pref_path'], pref
            global['fromfile'] = file_basename(file)
            asw_control, 'FROMFILETEXT', SET_VALUE = global['fromfile']
            pref['proj_file'] = ''                
        endif
    end

    'FILETO' : begin
        ;if ass_slit_widget_need_save() then return 
        file = dialog_pickfile(DEFAULT_EXTENSION = 'fits', FILTER = ['*.fits'], GET_PATH = path, PATH = pref['path'])
        if file ne '' then begin
            pref['path'] = path
            save, filename = pref['pref_path'], pref
            global['tofile'] = file_basename(file)
            asw_control, 'TOFILETEXT', SET_VALUE = global['tofile']  
            pref['proj_file'] = ''                
        endif
    end

    'ORDER' : begin
        fit_order = widget_info(asw_getctrl('ORDER'), /DROPLIST_SELECT)
        global['fit_order'] = ass_slit_widget_fit_orders(idx = fit_order, mode = 'fittype')
    end

    'FIT' : begin
        fittype = global['fit_order']
        limpts = ass_slit_widget_fit_orders(idx = fittype, mode = 'limit')
        if global['points'].Count() lt limpts then begin
            result = DIALOG_MESSAGE('Number of points for selected approximation should be no less than ' + asu_compstr(limpts) + '.', title = 'SlitTreat Error', /ERROR)
            return
        endif
            
        WIDGET_CONTROL, /HOURGLASS

        t0 = systime(/seconds)
        iter = ass_slit_widget_get_appr(global['points'], fittype, norm_poly, reper_pts, err = err)
        if err eq 1 then begin
            result = DIALOG_MESSAGE('Too many fitting iterations! Please try another markup.', title = 'SlitTreat Error', /ERROR)
            return
        endif    
        
        ; asu_sec2hms(systime(/seconds)-t0, /issecs)        
        message, 'Number of iteration = ' + asu_compstr(iter), /info

        ass_slit_widget_clear_appr
        global['reper_pts'] = reper_pts
        global['approx'] = asm_bezier_create_line(reper_pts, points = 1000) 
        ass_slit_widget_update_td
    end

    'EDITAPPR' : begin
        global['appredit'] = widget_info(asw_getctrl('EDITAPPR'), /BUTTON_SET)
        ass_slit_widget_show_image
    end

    'MODEMEAN' : begin
        global['slitmode'] = eventval
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit
    end     

    'MODEMED' : begin
        global['slitmode'] = eventval
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit 
    end     

    'MODEQ75' : begin
        global['slitmode'] = eventval
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit 
    end     

    'MODEQ95' : begin
        global['slitmode'] = eventval
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit 
    end     

    'SLITWIDTH' : begin
        asw_control, 'SLITWIDTH', GET_VALUE = pos
        global['slitwidth'] = pos
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit
    end
         
    'SLITCONTR' : begin
        asw_control, 'SLITCONTR', GET_VALUE = pos
        global['slitcontr'] = pos
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit
    end
         
    'SLITBRIGHT' : begin
        asw_control, 'SLITBRIGHT', GET_VALUE = pos
        global['slitbright'] = pos
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit
    end
         
    'CLEAR' : begin
        global['points'] = list()
        asw_control, 'IMAGE', GET_VALUE = drawID
        WSET, drawID
        erase
        ass_slit_widget_clear_appr
        ass_slit_widget_show_slit
    end

    'CLEARAPPR' : begin
        ass_slit_widget_clear_appr
        ass_slit_widget_show_slit
    end

    'SAVEAS' : begin
        if global['data_list'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to save!', title = 'SlitTreat Error', /ERROR)
            return
        endif    
        ass_slit_widget_save_as
    end

    'SAVE' : begin
        if global['data_list'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to save!', title = 'SlitTreat Error', /ERROR)
            return
        endif
            
        ass_slit_widget_save_as, /save_proj
    end

    'LOAD' : begin
        ass_slit_widget_load
    end

    'LAST' : begin
        ass_slit_widget_load, /last_proj
    end

    'EXPORT' : begin
        if global['straight'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to export!', title = 'SlitTreat Error', /ERROR)
            return
        endif    
        
        WIDGET_CONTROL, /HOURGLASS
        ass_slit_widget_export
    end

    'EXPSAV' : begin
        if global['straight'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to export!', title = 'SlitTreat Error', /ERROR)
            return
        endif    
        
        WIDGET_CONTROL, /HOURGLASS
        ass_slit_widget_export_sav
    end
    
    'EXPIMAGE' : begin
        if global['data_list'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to export!', title = 'SlitTreat Error', /ERROR)
            return
        endif    
        
        WIDGET_CONTROL, /HOURGLASS
        ass_slit_widget_export_image
    end
    
    'HIDEAPPR' : begin
        ass_slit_widget_show_image
    end
    
    'HIDEALL' : begin
        ass_slit_widget_show_image
    end
    
    'TDSCALES' : begin
        ass_slit_widget_show_slit
    end
    
    'FRATE' : begin
        asw_control, 'FRATE', GET_VALUE = rate
        global['framerate'] = rate
    end
    
    'START' : begin
        if global['data_list'] eq !NULL then return
        if global['animation'] then return
        global['animation'] = 1
        WIDGET_CONTROL, event.ID, TIMER = 0
    end
    
    'STOP' : begin
        global['animation'] = 0
    end
    
    'TIMER' : begin
        if global['animation'] eq 0 then return
        global['currpos'] += 1
        if global['currpos'] ge n_elements(global['data_ind']) then global['currpos'] = 0 
        asw_control, 'SLIDER', SET_VALUE = global['currpos']
        ind = global['data_ind', global['currpos']]
        asw_control, 'FRAMEDATE', SET_VALUE = ind.date_obs
        ass_slit_widget_show_image
        ass_slit_widget_show_slit
        
        WIDGET_CONTROL, event.id, TIMER = 1d/global['framerate']
    end
    
endcase
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_add_keys

common G_ASS_SLIT_WIDGET, global

if ~global.hasKey('slitcontr') then global['slitcontr'] = 0
if ~global.hasKey('slitbright') then global['slitbright'] = 100
if ~global.hasKey('framerate') then begin
    global['framerate'] = 5d
endif    
if ~global.hasKey('animation') then global['animation'] = 0
if ~global.hasKey('xmargin') then global['xmargin'] = [10, 1]
if ~global.hasKey('ymargin') then global['ymargin'] = [5, 1]
if ~global.hasKey('appredit') then global['appredit'] = 0
if ~global.hasKey('reper_pts') then begin
    reper_pts = !NULL
    if global['norm_poly'] ne !NULL then begin 
        asm_bezier_norm_vs_points, global['norm_poly'], reper_pts, 0
    endif
    global['reper_pts'] = reper_pts
    global['pt_to_drag'] = -1
endif

if ~global.hasKey('cadence') then global['cadence'] = 12d

if isa(global['fit_order'], /number) then global['fit_order'] = ass_slit_widget_fit_orders(idx = 0, mode = 'fittype')

end

;----------------------------------------------------------------------------------
pro SlitTreat_widget

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

asw_widget = hash()
global = hash()
pref = hash()
global['proj_name'] = ''
global['fromfile'] = ''
global['tofile'] = ''
global['workpath'] = ''
global['data_list'] = !NULL
global['data_ind'] = !NULL 
global['slit_list'] = !NULL
global['byte_list'] = !NULL
global['byte_info'] = !NULL
global['data_ind'] = !NULL
global['dat_range'] = lonarr(2, 2)
global['win_range'] = lonarr(2, 2)
global['xy_lb_dat'] = !NULL
global['xy_rt_dat'] = !NULL
global['currpos'] = 0
global['select'] = 0

global['points'] = list()
global['fit_order'] = 'linear'
global['norm_poly'] = !NULL
global['approx'] = !NULL
global['markup'] = !NULL
global['grids'] = !NULL
global['straight'] = !NULL
global['slitwidth'] = 1
global['slitmode'] = 'MODEMEAN'
global['speed_first_pt'] = !NULL
global['speed_list'] = list()

ass_slit_widget_add_keys

global['modified'] = 0

global['maxslitwidth'] = 100
winsize = [800, 800]
global['winsize'] = winsize
slitsize = [800, 400]
global['slitsize'] = slitsize

global['timedist'] = !NULL
global['timedistshow'] = !NULL

pref['path'] = ''
pref['proj_path'] = ''
pref['proj_file'] = ''
pref['export_path'] = ''
pref['expsav_path'] = ''
pref['pref_path'] = ''
dirpath = file_dirname((ROUTINE_INFO('SlitTreat_widget', /source)).path, /mark)
if n_elements(dirpath) gt 0 then begin
    pref['pref_path'] = dirpath + 'slittreat.pref'
    if file_test(pref['pref_path']) then begin
        restore, pref['pref_path']
    endif    
endif    

base = WIDGET_BASE(TITLE = 'SlitTreat', UNAME = 'SLITTREAT', /column, /TLB_KILL_REQUEST_EVENTS)
asw_widget['widbase'] = base

filecol = WIDGET_BASE(base, /column)
    fromrow = WIDGET_BASE(filecol, /row)
        dummy = WIDGET_LABEL(fromrow, VALUE = 'From: ', XSIZE = 40)
        fromfiletext = WIDGET_TEXT(fromrow, UNAME = 'FROMFILETEXT', VALUE = '', XSIZE = 120, YSIZE = 1, /FRAME)
        frombutton = WIDGET_BUTTON(fromrow, VALUE = '...', UVALUE = 'FILEFROM', SCR_XSIZE = 30)
    torow = WIDGET_BASE(filecol, /row)
        dummy = WIDGET_LABEL(torow, VALUE = 'To: ', XSIZE = 40)
        tofiletext = WIDGET_TEXT(torow, UNAME = 'TOFILETEXT', VALUE = '', XSIZE = 120, YSIZE = 1, /FRAME)
        frombutton = WIDGET_BUTTON(torow, VALUE = '...', UVALUE = 'FILETO', SCR_XSIZE = 30)

mainrow = WIDGET_BASE(base, /row)
    imagecol = WIDGET_BASE(mainrow, /column)
        showimage = WIDGET_DRAW(imagecol, GRAPHICS_LEVEL = 0, UNAME = 'IMAGE', UVALUE = 'IMAGE', XSIZE = winsize[0], YSIZE = winsize[1], /BUTTON_EVENTS)
        slider = WIDGET_SLIDER(imagecol, VALUE = 0, UNAME = 'SLIDER', UVALUE = 'SLIDER', XSIZE = winsize[0])
        framerow = WIDGET_BASE(imagecol, /row)
            dummy = WIDGET_LABEL(framerow, VALUE = 'Frame', XSIZE = 40)
            framedate = WIDGET_TEXT(framerow, UNAME = 'FRAMEDATE', VALUE = '', XSIZE = 30, YSIZE = 1, /FRAME)
            startbutton = WIDGET_BUTTON(framerow, VALUE = 'Start', UVALUE = 'START', XSIZE = 80)
            stopbutton = WIDGET_BUTTON(framerow, VALUE = 'Stop', UVALUE = 'STOP', XSIZE = 80)
            dummy = WIDGET_LABEL(framerow, VALUE = '    fps:', XSIZE = 30)
            rate = WIDGET_SLIDER(framerow, VALUE = round(global['framerate']), MINIMUM = 1, MAXIMUM = 20, UNAME = 'FRATE', UVALUE = 'FRATE', XSIZE = 90)
            
    ctrlcol = WIDGET_BASE(mainrow, /column, /align_left)
        procbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Proceed Files', UVALUE = 'PROCEED', XSIZE = 100)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        saveasbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Save As ...', UVALUE = 'SAVEAS', XSIZE = 80)
        savebutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Save', UVALUE = 'SAVE', XSIZE = 80)
        loadbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Load ...', UVALUE = 'LOAD', XSIZE = 80)
        lastbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Last', UVALUE = 'LAST', XSIZE = 80)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        winfitrow = WIDGET_BASE(ctrlcol, /column, /Exclusive)
            size1 = WIDGET_BUTTON(winfitrow, VALUE = 'Fit to Window', UNAME = 'FITWIN', UVALUE = 'FITWIN', XSIZE = 80)
            size2 = WIDGET_BUTTON(winfitrow, VALUE = 'Actual Size', UNAME = 'ACTSIZE', UVALUE = 'ACTSIZE', XSIZE = 80)
            size3 = WIDGET_BUTTON(winfitrow, VALUE = 'Selection', UNAME = 'SELWIN', UVALUE = 'SELWIN', XSIZE = 80)
            WIDGET_CONTROL, size1, SET_BUTTON = 1
            global['drawmode'] = 'FITWIN'
        ;selinforow = WIDGET_BASE(ctrlcol, /column)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = '     (Ctrl + Left Mouse)', XSIZE = 100)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        orderbutton = WIDGET_DROPLIST(ctrlcol, VALUE = ass_slit_widget_fit_orders(), UNAME = 'ORDER', UVALUE = 'ORDER', XSIZE = 80)
        fitbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Fit', UVALUE = 'FIT', XSIZE = 100)
        editapprrow = WIDGET_BASE(ctrlcol, /column, /Nonexclusive)
            editapprcheck = WIDGET_BUTTON(editapprrow, VALUE = 'Edit Approx. ...', UNAME = 'EDITAPPR', UVALUE = 'EDITAPPR', XSIZE = 100)
        hiderow = WIDGET_BASE(ctrlcol, /column, /Nonexclusive)
            hidecheck = WIDGET_BUTTON(hiderow, VALUE = 'Hide Markup', UNAME = 'HIDEAPPR', UVALUE = 'HIDEAPPR', XSIZE = 100)
        hideallrow = WIDGET_BASE(ctrlcol, /column, /Nonexclusive)
            hideallcheck = WIDGET_BUTTON(hideallrow, VALUE = 'Hide All', UNAME = 'HIDEALL', UVALUE = 'HIDEALL', XSIZE = 100)
        clearbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Clear Slit', UVALUE = 'CLEAR', XSIZE = 80)
        clearapprbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Clear Approx.', UVALUE = 'CLEARAPPR', XSIZE = 80)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        exportimage = WIDGET_BUTTON(ctrlcol, VALUE = 'Export Image ...', UVALUE = 'EXPIMAGE', XSIZE = 80)
        
    slitcol = WIDGET_BASE(mainrow, /column, /base_align_left) ;xsize = slitsize[0])
        tdcoords = WIDGET_LABEL(slitcol, VALUE = '', XSIZE = slitsize[0], UNAME = 'TDCOORDS', UVALUE = 'TDCOORDS', /align_center)
        slitimage = WIDGET_DRAW(slitcol, GRAPHICS_LEVEL = 0, UNAME = 'SLIT', UVALUE = 'SLIT', XSIZE = slitsize[0], YSIZE = slitsize[1], /BUTTON_EVENTS)
        markrow = WIDGET_BASE(slitcol, /row)
            tdfrom = WIDGET_LABEL(markrow, VALUE = '', XSIZE = 120, UNAME = 'TDFROM', UVALUE = 'TDFROM')
            tdlength = WIDGET_LABEL(markrow, VALUE = '', XSIZE = slitsize[0] - 240, /align_center, UNAME = 'TDLNG', UVALUE = 'TDLNG')
            tdto = WIDGET_LABEL(markrow, VALUE = '', XSIZE = 120, /align_right, UNAME = 'TDTO', UVALUE = 'TDTO')
        moderow = WIDGET_BASE(slitcol, /row, /Exclusive)
            modemean = WIDGET_BUTTON(moderow, VALUE = 'Mean', UNAME = 'MODEMEAN', UVALUE = 'MODEMEAN', XSIZE = 80)
            modemed = WIDGET_BUTTON(moderow, VALUE = 'Median', UNAME = 'MODEMED', UVALUE = 'MODEMED', XSIZE = 80)
            modeq75 = WIDGET_BUTTON(moderow, VALUE = '75 %', UNAME = 'MODEQ75', UVALUE = 'MODEQ75', XSIZE = 80)
            modeq95 = WIDGET_BUTTON(moderow, VALUE = '95 %', UNAME = 'MODEQ95', UVALUE = 'MODEQ95', XSIZE = 80)
            WIDGET_CONTROL, modemean, SET_BUTTON = 1
        slitwidth = WIDGET_SLIDER(slitcol, VALUE = 0, UNAME = 'SLITWIDTH', UVALUE = 'SLITWIDTH', XSIZE = slitsize[0], title = 'Time-Distance Halfwidth')
        BCrow = WIDGET_BASE(slitcol, /row)
            slitcontr = WIDGET_SLIDER(BCrow, VALUE = 0, UNAME = 'SLITCONTR', UVALUE = 'SLITCONTR', XSIZE = slitsize[0]/2, title = 'Time-Distance Contrast')
            slitbright = WIDGET_SLIDER(BCrow, VALUE = 100, UNAME = 'SLITBRIGHT', UVALUE = 'SLITBRIGHT', XSIZE = slitsize[0]/2, title = 'Time-Distance Upper Threshold')
        dummy = WIDGET_LABEL(slitcol, VALUE = ' ', XSIZE = 40)
;        scalesrow = WIDGET_BASE(slitcol, /column, /Nonexclusive)
;            scalescheck = WIDGET_BUTTON(scalesrow, VALUE = 'Show Scales', UNAME = 'TDSCALES', UVALUE = 'TDSCALES', XSIZE = 100)
        dummy = WIDGET_LABEL(slitcol, VALUE = ' ', XSIZE = 40)
        exportbutton = WIDGET_BUTTON(slitcol, VALUE = 'Export T-D ...', UVALUE = 'EXPORT', XSIZE = 80)
        expsavbutton = WIDGET_BUTTON(slitcol, VALUE = 'T-D to SAV...', UVALUE = 'EXPSAV', XSIZE = 80)

WIDGET_CONTROL, base, /REALIZE
XMANAGER, 'ass_slit_widget_buttons', base, GROUP_LEADER = GROUP, /NO_BLOCK

WIDGET_CONTROL, slitwidth, SET_SLIDER_MIN = 1
WIDGET_CONTROL, slitwidth, SET_SLIDER_MAX = global['maxslitwidth']
WIDGET_CONTROL, slitcontr, SET_SLIDER_MIN = -100
WIDGET_CONTROL, slitcontr, SET_SLIDER_MAX = 100
WIDGET_CONTROL, slitbright, SET_SLIDER_MIN = 0
WIDGET_CONTROL, slitbright, SET_SLIDER_MAX = 100
WIDGET_CONTROL, slitbright, SET_VALUE = global['slitbright']

;ass_slit_widget_set_win, 'IMAGE', 'winsize'
;ass_slit_widget_set_win, 'SLIT', 'slitsize'

end