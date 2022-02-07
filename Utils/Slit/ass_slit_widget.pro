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
pro ass_slit_widget_set_win, ctrl, wsize
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

asw_control, ctrl, GET_VALUE = drawID
WSET, drawID
winsize = global[wsize]
base = dblarr(winsize[0], winsize[1])
tvplot, base, indgen(winsize[0]), indgen(winsize[1]), /fit_window, xmargin = [0, 0], ymargin = [0, 0], /nodata, xmajor = 0, xminor = 0, ymajor = 0, yminor = 0

end

;----------------------------------------------------------------------------------
function ass_slit_widget_slit_convert, event_xy 
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

slitsize = global['slitsize']
sz = size(global['straight']) ; slit x length x frames

data_xy = dblarr(2)
data_xy[0] = double(event_xy[0])/slitsize[0]*sz[3]  
data_xy[1] = double(event_xy[1])/slitsize[1]*sz[2]  

return, data_xy

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
    global['timedist'] = total(slit, 1)
endif else begin
    case global['slitmode'] of
        'MODEMEAN': begin
            global['timedist'] = mean(slit, dimension = 1)
        end    
        'MODEMED': begin
            global['timedist'] = median(slit, dimension = 1)
        end        
        'MODEQ75': begin
            global['timedist'] = ass_slit_widget_get_percentil(slit, 0.75)
        end        
        'MODEQ95': begin
            global['timedist'] = ass_slit_widget_get_percentil(slit, 0.95)
        end
    endcase            
endelse    

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_apply_contr
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

showslit = global['timedist']
pos = global['slitcontr']

ms = max(showslit)
showslit /= ms
contrv = double(pos)/30d
if contrv gt 0 then begin
    contr = contrv*2d + 1
endif else begin
    contr = 1d - abs(contrv)
endelse    
global['timedistshow'] = global['timedist']^contr

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_show_slit
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['timedist'] eq !NULL then return

pos = global['slitcontr']

ass_slit_widget_apply_contr

asw_control, 'SLIT', GET_VALUE = drawID
WSET, drawID
;aia_lct_silent,wave = 171,/load
;tvscl, td
device, decomposed = 0
loadct, 0, /silent
implot, transpose(global['timedistshow'], [1, 0]), /fit_window, xmargin = [0, 0], ymargin = [0, 0], xmajor = 0, xminor = 0, ymajor = 0, yminor = 0

slitsize = global['slitsize']
p = global['currpos']

;loadct, 13, /silent
device, decomposed = 1
oplot, [p, p], [0, slitsize[1]], color = 'FF0000'x, thick = 1.5

slist = global['speed_list']
for k = 0, slist.Count()-1 do begin
    crds = slist[k]
    crd0 = ass_slit_widget_slit_convert(crds.first)
    crd1 = ass_slit_widget_slit_convert(crds.second)
    oplot, [crd0[0], crd1[0]], [crd0[1], crd1[1]], color = '00FF00'x, thick = 1.5
    oplot, [crd0[0]], [crd0[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
    oplot, [crd1[0]], [crd1[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
    
    duration = (crd1[0] - crd0[0]) * 12d ; seconds in 1 hor pixel
    pos_km = (crd1[1] - crd0[1]) * 0.6d * 725; km in 1 vert pixel  
    speed = round( pos_km / duration / 10d) * 10
    sstr = strcompress(string(abs(speed), format = '(%"%5d")'), /remove_all) + ' km/s'

    align = speed gt 0 ? 1.0 : 0.0
    XYOUTS, (crd0[0]+crd1[0])/2, (crd0[1]+crd1[1])/2, sstr, color = '0000FF'x, alignment = align, charsize = 1.8, charthick = 1.5 
endfor

if global['speed_first_pt'] ne !NULL then begin
    crd0 = ass_slit_widget_slit_convert(global['speed_first_pt'])
    oplot, [crd0[0]], [crd0[1]], psym = 2, symsize = 1.5, thick = 1.5, color = '00FF00'x
endif

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
if drag then begin
    tv, global['byte_list', *, *, p]
endif else begin
    implot, base, xmargin = [0, 0], ymargin = [0, 0], xmajor = 0, xminor = 0, ymajor = 0, yminor = 0
endelse        

;wait, 0.1

device, decomposed = 1
if global['points'].Count() gt 0 then begin
;    loadct, 13, /silent
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
asw_control, 'SLIT', GET_VALUE = drawID
WSET, drawID
erase
;ass_slit_widget_set_win, 'IMAGE', 'winsize'
ass_slit_widget_show_image

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_save_as
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

asw_control, 'FROMFILETEXT', GET_VALUE = str
expr = stregex(str, '.*([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9][0-9][0-9][0-9][0-9]).*',/subexpr,/extract)
global['proj_name'] = expr[1]
file = dialog_pickfile(DEFAULT_EXTENSION = 'spr', FILTER = ['*.spr'], GET_PATH = path, PATH = pref['proj_path'], file = expr[1], /write, /OVERWRITE_PROMPT)
if file ne '' then begin
    WIDGET_CONTROL, /HOURGLASS
    pref['proj_path'] = path
    pref['proj_file'] = file
    save, filename = pref['pref_path'], pref 
    save, filename = file, global

    ass_slit_widget_set_ctrl
endif
        
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_load
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASS_SLIT_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

file = dialog_pickfile(DEFAULT_EXTENSION = 'spr', FILTER = ['*.spr'], GET_PATH = path, PATH = pref['proj_path'], file = pref['proj_file'], /read, /must_exist)
if file eq '' then return

WIDGET_CONTROL, /HOURGLASS

pref['proj_path'] = path
pref['proj_file'] = file
save, filename = pref['pref_path'], pref
restore, file

ass_slit_widget_set_ctrl

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

from_crd = dblarr(2)
from_crd[0] = first.xcen + first.cdelt1*(xy[0,0] - double(szd[1])/2d)
from_crd[1] = first.ycen + first.cdelt2*(xy[1,0] - double(szd[2])/2d)
to_crd = dblarr(2)
to_crd[0] = last.xcen + last.cdelt1*(xy[0,-1] - double(szd[1])/2d)
to_crd[1] = last.ycen + last.cdelt2*(xy[0,-1] - double(szd[2])/2d)

from_time = first.date_obs
to_time = last.date_obs

half_width = global['slitwidth']
mode = global['slitmode']

save, filename = file, timedist, from_crd, to_crd, from_time, to_time, half_width, mode

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

if global['proj_name'] ne '' then asw_control, 'SLITZILLA', BASE_SET_TITLE = 'SlitZilla - ' + global['proj_name']

asw_control, 'FROMFILETEXT', SET_VALUE = global['fromfile']
asw_control, 'TOFILETEXT', SET_VALUE = global['tofile']
asw_control, global['drawmode'], SET_BUTTON = 1
asw_control, 'ORDER', SET_DROPLIST_SELECT = global['fit_order']
sz = size(global['data_list'])
asw_control, 'SLIDER', SET_SLIDER_MIN = 1
asw_control, 'SLIDER', SET_SLIDER_MAX = sz[3]
asw_control, 'SLIDER', SET_VALUE = global['currpos'] + 1

ind = global['data_ind', global['currpos']]
asw_control, 'FRAMEDATE', SET_VALUE = ind.date_obs

asw_control, 'SLITWIDTH', SET_VALUE = global['slitwidth']
asw_control, global['slitmode'], SET_BUTTON = 1

if ~global.hasKey('slitcontr') then begin
    global['slitcontr'] = 0
endif    
asw_control, 'SLITCONTR', SET_VALUE = global['slitcontr']

ass_slit_widget_set_win, 'IMAGE', 'winsize'
ass_slit_widget_show_image
ass_slit_widget_set_win, 'SLIT', 'slitsize'
ass_slit_widget_get_timedist
ass_slit_widget_show_slit

end

;----------------------------------------------------------------------------------
function ass_slit_widget_need_save
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['data_list'] ne !NULL then begin
    result = DIALOG_MESSAGE('All results will be lost! Exit anyway?', title = 'SlitZilla', /QUESTION)
    return, result eq 'Yes' ? 0 : 1
endif else begin
    return, 0
endelse    

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

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

case eventval of
    'SLIT' : begin
        if event.type eq 0 then begin
            case event.press of
                1: begin
                    if global['speed_first_pt'] eq !NULL then begin
                        global['speed_first_pt'] = [event.x, event.y]
                    endif else begin
                        global['speed_list'].Add, {first:global['speed_first_pt'], second:[event.x, event.y]}
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
;        sname = TAG_NAMES(event, /STRUCTURE_NAME)
;        case sname of
;            'WIDGET_DRAW': print, 'Draw, Type=' + string(event.type) + ' Press=' + string(event.press*1L) + ' Release=' + string(event.release*1L) + ' x=' + string(event.x) + ' y=' + string(event.y) $
;                                + ' Clicks=' + string(event.clicks) + ' Mod=' + string(event.modifiers) + ' Key=' + string(event.key)
;        endcase
        if event.type eq 0 and event.modifiers eq 2 then begin
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
                        1: begin
                            xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
                            if ~ass_slit_widget_in_scope(xy) then return
                            global['points'].Add, {x:xy[0], y:xy[1]}
                        end
                        
                        4: begin
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
                    WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 0
                    if global['select'] eq 1 then begin
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
        ass_slit_widget_show_slit
        ;ass_slit_widget_set_win, 'IMAGE', 'winsize'
        ass_slit_widget_show_image
    end
        
    'ACTSIZE' : begin
        ;ass_slit_widget_set_win, 'IMAGE', 'winsize'
        ass_slit_widget_show_image, mode = 'ACTSIZE' 
    end
    'FITWIN' : begin
        ;ass_slit_widget_set_win, 'IMAGE', 'winsize'
        ass_slit_widget_show_image, mode = 'FITWIN'
    end
    'SELWIN' : begin
        ;ass_slit_widget_set_win, 'IMAGE', 'winsize'
        ass_slit_widget_show_image, mode = 'SELWIN'
    end
        
    'PROCEED' : begin
        ;if ass_slit_widget_need_save() then return 
        WIDGET_CONTROL, /HOURGLASS
        global['data_list'] = asu_get_file_sequence_data(pref['path'], global['fromfile'], global['tofile'], ind = ind, err = err)
        global['data_ind'] = ind 
        case err of
            1: result = DIALOG_MESSAGE('Please select both first and last files!', title = 'SlitZilla Error', /ERROR)
            2: result = DIALOG_MESSAGE('Not enough files found!', title = 'SlitZilla Error', /ERROR)
            else: begin
                global['currpos'] = 0
                global['byte_list'] = !NULL
                global['slit_list'] = !NULL
                asw_control, 'FITWIN', SET_BUTTON = 1
                ass_slit_widget_show_image, mode = 'FITWIN'
                sz = size(global['data_list'])
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
        global['fit_order'] = widget_info(asw_getctrl('ORDER'), /DROPLIST_SELECT)
    end

    'FIT' : begin
        order = global['fit_order'] + 1
        limpts = 2
        case order of
            1: limpts = 2
            2: limpts = 7
            3: limpts = 9
        endcase
        if global['points'].Count() lt limpts then begin
            result = DIALOG_MESSAGE('Number of points for selected approximation shoul be no less than ' + asu_compstr(limpts), title = 'SlitZilla Error', /ERROR)
            return
        endif
            
        WIDGET_CONTROL, /HOURGLASS

        ass_slit_widget_clear_appr
        
        iter = ass_slit_widget_get_appr(global['points'], global['fit_order'], norm_poly, reper_pts)
        
;        np = global['points'].Count()
;        x = dblarr(np) 
;        y = dblarr(np) 
;        for k = 0, np-1 do begin
;            x[k] = (global['points'])[k].x 
;            y[k] = (global['points'])[k].y 
;        endfor    
;        
;        order = global['fit_order'] + 1
;        maxdist = asm_bezier_appr(x, y, order, result, iter, simpseed = simpseed, tlims = tlims)
        global['norm_poly'] = norm_poly
        
        message, 'Number of iteration = ' + asu_compstr(iter), /info
        
        np = 1000
        ;tset = asu_linspace(tlims[0], tlims[1], np)
        tset = asu_linspace(0d, 1d, np)
        xy = dblarr(2, np)
        for k = 0, np-1 do begin
;            xy[0, k] = poly(tset[k], norm_poly.x_poly)
;            xy[1, k] = poly(tset[k], norm_poly.y_poly)
            xy[0, k] = asm_bezier_poly_pts(tset[k], reper_pts.x_pts)
            xy[1, k] = asm_bezier_poly_pts(tset[k], reper_pts.y_pts)
        endfor
        global['approx'] = xy
        
        step1 = 1d
        markup = asm_bezier_markup_curve_eqv(norm_poly, [0, 1], step1)
        global['markup'] = markup
        
        step2 = 1d
        hwidth = global['maxslitwidth']
        grids = asm_bezier_markup_normals(norm_poly, markup[2, *], step2, hwidth) ; returns {x_grid:x_grid, y_grid:y_grid}
        global['grids'] = grids
        
        straight = ass_slit_data2grid(global['data_list'], grids)
        global['straight'] = straight
        
        ass_slit_widget_set_win, 'IMAGE', 'winsize'
        ass_slit_widget_show_image
        ass_slit_widget_set_win, 'SLIT', 'slitsize'
        ass_slit_widget_get_timedist
        ass_slit_widget_show_slit
    end

    'EDITAPPR' : begin
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
            result = DIALOG_MESSAGE('Nothing to save!', title = 'SlitZilla Error', /ERROR)
            return
        endif    
        ass_slit_widget_save_as
    end

    'SAVE' : begin
        if global['data_list'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to save!', title = 'SlitZilla Error', /ERROR)
            return
        endif    
        WIDGET_CONTROL, /HOURGLASS
        if file_test(pref['proj_file']) then begin
            save, filename = pref['proj_file'], global
        endif else begin
            ass_slit_widget_save_as
        endelse
    end

    'LOAD' : begin
        ass_slit_widget_load
    end

    'LAST' : begin
        WIDGET_CONTROL, /HOURGLASS
        if file_test(pref['proj_file']) then begin
            restore, pref['proj_file']
            ass_slit_widget_set_ctrl
        endif else begin
            ass_slit_widget_load
        endelse    
    end

    'EXPORT' : begin
        if global['straight'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to export!', title = 'SlitZilla Error', /ERROR)
            return
        endif    
        
        WIDGET_CONTROL, /HOURGLASS
        ass_slit_widget_export
    end

    'EXPSAV' : begin
        if global['straight'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to export!', title = 'SlitZilla Error', /ERROR)
            return
        endif    
        
        WIDGET_CONTROL, /HOURGLASS
        ass_slit_widget_export_sav
    end
    
    'EXPIMAGE' : begin
        if global['data_list'] eq !NULL then begin
            result = DIALOG_MESSAGE('Nothing to export!', title = 'SlitZilla Error', /ERROR)
            return
        endif    
        
        WIDGET_CONTROL, /HOURGLASS
        ass_slit_widget_export_image
    end
    
endcase
end

;----------------------------------------------------------------------------------
pro ass_slit_widget

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
global['fit_order'] = 0
global['norm_poly'] = !NULL
global['approx'] = !NULL
global['markup'] = !NULL
global['grids'] = !NULL
global['straight'] = !NULL
global['slitwidth'] = 1
global['slitcontr'] = 0
global['slitmode'] = 'MODEMEAN'
global['speed_first_pt'] = !NULL
global['speed_list'] = list()

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
dirpath = file_dirname((ROUTINE_INFO('ass_slit_widget', /source)).path, /mark)
if n_elements(dirpath) gt 0 then begin
    pref['pref_path'] = dirpath + 'slitzilla.pref'
    if file_test(pref['pref_path']) then begin
        restore, pref['pref_path']
    endif    
endif    

base = WIDGET_BASE(TITLE = 'SlitZilla', UNAME = 'SLITZILLA', XSIZE = 1750, /column, /TLB_KILL_REQUEST_EVENTS)
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
    ctrlcol = WIDGET_BASE(mainrow, /column)
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
        selinforow = WIDGET_BASE(ctrlcol, /column)
            dummy = WIDGET_LABEL(selinforow, VALUE = '     (Ctrl + Left Mouse)', XSIZE = 100)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        orderbutton = WIDGET_DROPLIST(ctrlcol, VALUE = ['Linear', '2nd Order', '3rd Order'], UNAME = 'ORDER', UVALUE = 'ORDER', XSIZE = 80)
        fitbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Fit', UVALUE = 'FIT', XSIZE = 100)
        editapprrow = WIDGET_BASE(ctrlcol, /column, /Nonexclusive)
            editapprbutton = WIDGET_BUTTON(editapprrow, VALUE = 'Edit Approx. ...', UVALUE = 'EDITAPPR', XSIZE = 100)
        clearbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Clear Slit', UVALUE = 'CLEAR', XSIZE = 80)
        clearapprbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Clear Approx.', UVALUE = 'CLEARAPPR', XSIZE = 80)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        exportbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Export T-D ...', UVALUE = 'EXPORT', XSIZE = 80)
        expsavbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'T-D to SAV...', UVALUE = 'EXPSAV', XSIZE = 80)
        dummy = WIDGET_LABEL(ctrlcol, VALUE = ' ', XSIZE = 40)
        exportimage = WIDGET_BUTTON(ctrlcol, VALUE = 'Export Image ...', UVALUE = 'EXPIMAGE', XSIZE = 80)
    slitcol = WIDGET_BASE(mainrow, /column)
        slitimage = WIDGET_DRAW(slitcol, GRAPHICS_LEVEL = 0, UNAME = 'SLIT', UVALUE = 'SLIT', XSIZE = slitsize[0], YSIZE = slitsize[1], /BUTTON_EVENTS)
        moderow = WIDGET_BASE(slitcol, /row, /Exclusive)
            modemean = WIDGET_BUTTON(moderow, VALUE = 'Mean', UNAME = 'MODEMEAN', UVALUE = 'MODEMEAN', XSIZE = 80)
            modemed = WIDGET_BUTTON(moderow, VALUE = 'Median', UNAME = 'MODEMED', UVALUE = 'MODEMED', XSIZE = 80)
            modeq75 = WIDGET_BUTTON(moderow, VALUE = '75 %', UNAME = 'MODEQ75', UVALUE = 'MODEQ75', XSIZE = 80)
            modeq95 = WIDGET_BUTTON(moderow, VALUE = '95 %', UNAME = 'MODEQ75', UVALUE = 'MODEQ75', XSIZE = 80)
            WIDGET_CONTROL, modemean, SET_BUTTON = 1
        slitwidth = WIDGET_SLIDER(slitcol, VALUE = 0, UNAME = 'SLITWIDTH', UVALUE = 'SLITWIDTH', XSIZE = slitsize[0])
        swrow = WIDGET_BASE(slitcol, /row)
            dummy = WIDGET_LABEL(swrow, VALUE = 'Time-Distant Halfwidth', XSIZE = 120)
        slitcontr = WIDGET_SLIDER(slitcol, VALUE = 0, UNAME = 'SLITCONTR', UVALUE = 'SLITCONTR', XSIZE = slitsize[0])
        swrow = WIDGET_BASE(slitcol, /row)
            dummy = WIDGET_LABEL(swrow, VALUE = 'Time-Distant Contrast', XSIZE = 120)

WIDGET_CONTROL, base, /REALIZE
XMANAGER, 'ass_slit_widget_buttons', base, GROUP_LEADER = GROUP, /NO_BLOCK

WIDGET_CONTROL, slitwidth, SET_SLIDER_MIN = 1
WIDGET_CONTROL, slitwidth, SET_SLIDER_MAX = global['maxslitwidth']
WIDGET_CONTROL, slitcontr, SET_SLIDER_MIN = -30
WIDGET_CONTROL, slitcontr, SET_SLIDER_MAX = 30

ass_slit_widget_set_win, 'IMAGE', 'winsize'
ass_slit_widget_set_win, 'SLIT', 'slitsize'

end