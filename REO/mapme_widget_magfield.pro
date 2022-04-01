pro mapme_widget_event_mask_show, event
compile_opt idl2

mapme_widget_update_mf_draw

end

;-------------------------------------------------------------------------
pro mapme_widget_update_slider
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if global['magfield'] eq !NULL then return

asw_control, 'BSLIDE', GET_VALUE = pos
global['curr_height'] = pos

mapme_widget_update_mf_draw

end

;-------------------------------------------------------------------------
pro mapme_widget_event_slide, event
compile_opt idl2

mapme_widget_update_slider

end

;-------------------------------------------------------------------------
pro mapme_widget_event_magfile, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

file = dialog_pickfile(DEFAULT_EXTENSION = 'sav', FILTER = ['*.sav'], GET_PATH = path, PATH = pref['path'])
if file ne '' then begin
    pref['path'] = path
    save, filename = pref['pref_path'], pref
    global['magfile'] = file_basename(file)
    asw_control, 'MAGFILETEXT', SET_VALUE = global['magfile']
    pref['proj_file'] = ''
    WIDGET_CONTROL, /HOURGLASS
    mapme_widget_magfield               
endif

end

;-------------------------------------------------------------------------
pro mapme_widget_update_mf_draw
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

p = global['curr_height']

asw_control, 'FIELD', GET_VALUE = drawID
WSET, drawID
device, decomposed = 0
loadct, 0, /silent
; tv, local['bz', *, *, p]; , x,y ;,/iso,title = jtitle
implot, local['bz', *, *, p], xticks = 1, yticks = 1, xmargin = [0, 0], ymargin = [0, 0] ; , x,y ;,/iso,title = jtitle

; device, decomposed = 1
; loadct, 13, /silent
; c_colors = [50, 150. 255]
;asu_set_base_color
;c_colors = [asu_gci('r'), asu_gci('g'), asu_gci('b')]

device, decomposed = 1
c_colors = ['0000ff'x, '00ff00'x, 'ff0000'x]

x = local['b_x']
y = local['b_y']
contour, local['babs', *, *, p], x, y, levels = [500, 1200, 2000], c_annotation = ['4', '10', '18'], c_colors = c_colors, /overplot

asw_control, 'MASK', GET_VALUE = drawID
WSET, drawID
device, decomposed = 0
as_mask = widget_info(asw_getctrl('SHOWMASK'), /BUTTON_SET)
if as_mask then begin
    loadct, pref['colortab'], /silent
    tv, local['byte_mask']
endif else begin
    loadct, 0, /silent
    tv, local['byte_cont']
endelse    

mfodata = global['mfodata']

step = mfodata.dkm
s = string(step*pos) 
;mf_h = WIDGET_LABEL(sinfocol, VALUE = '                    ', UNAME = 'HEIGHT_MM', XSIZE = 150)
;mf_bz = WIDGET_LABEL(sinfocol, VALUE = '                    ', UNAME = 'BZ_RANGE', XSIZE = 150)
;mf_ba = WIDGET_LABEL(sinfocol, VALUE = '                    ', UNAME = 'BABS_MAX', XSIZE = 150)


end

;-------------------------------------------------------
pro mapme_widget_get_3D_data, winsize, data, ind_scaled, common_scaled
compile_opt idl2

res = asu_get_data_keep_ratio(winsize, data)

mm = minmax(res)   
common_scaled = (res - mm[0])/(mm[1] - mm[0]) * 255d
ind_scaled = res
sz = size(res)
for k = 0, sz[3]-1 do begin
    mm = minmax(res[*, *, k])   
;    ind_scaled[*, *, k] = (res[*, *, k] - mm[0])/(mm[1] - mm[0]) * 255d
    ind_scaled[*, *, k] = bytscl(res[*, *, k])
endfor    

end

;-------------------------------------------------------
pro mapme_widget_magfield
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if global['magfile'] eq '' then return

restore, pref['path'] + global['magfile']
if ~keyword_set(mfodata) then begin
    result = DIALOG_MESSAGE('Selected file does not contain magnetic field information.', title = 'MapMe Error', /ERROR)
    return
end

global['mfodata'] = mfodata
t = mfodata.obstime
t = str_replace(t, 'T', ' ')
asw_control, 'MFDATETIME', SET_VALUE = t

lon = round(mfodata.lon_cen)
lonl = lon lt 0 ? 'E' : 'W'
lat = round(mfodata.lat_cen)
latl = lat lt 0 ? 'S' : 'N'
pos = lonl + string(abs(lon), format='(%"%02d")') + ' ' + latl + string(abs(lat), format='(%"%02d")')  
asw_control, 'MFCENTER', SET_VALUE = pos

sz = size(mfodata.bz)
s = string(sz[1], format='(%"%d")') + ' x ' + string(sz[2], format='(%"%d")') + ' (x ' + string(sz[3], format='(%"%d")') + ')'
asw_control, 'MFSIZE', SET_VALUE = s

sz = size(mfodata.bz)
asu_get_par_keep_ratio, global['winsize'], sz[1:2], newsize, coef, win_range, dat_range, x = x, y = y
local['b_x'] = x 
local['b_y'] = y 

mapme_widget_get_3D_data, global['winsize'], mfodata.bz, ind, comm
local['bz_ind'] = ind 
local['bz'] = comm 
local['babs'] = sqrt(mfodata.bx^2 + mfodata.by^2 + mfodata.bz^2)

mfodata.model_mask[0, 0] = 1
mfodata.model_mask[0, 1] = 7

mask = bytscl(asu_get_data_keep_ratio(global['winsize'], mfodata.model_mask))
local['byte_mask'] = mask

mask = bytscl(asu_get_data_keep_ratio(global['winsize_c'], mfodata.model_mask))
local['byte_mask_c'] = mask

cont = bytscl(asu_get_data_keep_ratio(global['winsize'], mfodata.IC))
local['byte_cont'] = cont

asw_control, 'BSLIDE', SET_SLIDER_MIN = 0
asw_control, 'BSLIDE', SET_SLIDER_MAX = sz[3]-1
global['curr_height'] = 0
asw_control, 'BSLIDE', SET_VALUE = global['curr_height']

mapme_widget_update_mf_draw
mapme_widget_update_slider

end
