pro mapme_widget_magfield_update_event, event
compile_opt idl2

mapme_widget_update_mf_draw

end

;-------------------------------------------------------------------------
pro mapme_widget_update_slider
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if global['gxbox'] eq !NULL then return

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
pro mapme_widget_magfield_harms, p_h, freqs, showit, harm, color 
compile_opt idl2

common G_REO_WIDGET_LOCAL, local

if ~showit then return

levels = freqs/double(harm)/2.799e-3
annots = strarr(n_elements(freqs))
for k = 0, n_elements(freqs)-1 do begin
    annots[k] = asu_compstr(string(round(freqs[k]*10d)/10d, format = '(%"%4.1f")'))
endfor    

x = local['b_x']
y = local['b_y']
contour, local['babs_val', *, *, p_h], x, y, levels = levels, c_annotation = annots, c_colors = color, c_charthick = 1.5, c_charsize = 1.5, c_thick = 2, /overplot

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

bind = widget_info(asw_getctrl('IND_SCALE'), /BUTTON_SET)
bshow = widget_info(asw_getctrl('B_MODE'), /BUTTON_SET)
s = ''
if bind then s = '_ind'
bval = bshow ? local['babs'+s, *, *, p] : local['bz'+s, *, *, p]

asu_tvplot, bval

; device, decomposed = 1
; loadct, 13, /silent
; c_colors = [50, 150. 255]
;asu_set_base_color
;c_colors = [asu_gci('r'), asu_gci('g'), asu_gci('b')]

device, decomposed = 1
c_colors = ['0000ff'x, '00ff00'x, 'ff0000'x]

asw_control, 'EDIT_FREQ', GET_VALUE = sfreqs
freqs = asu_parse_list(sfreqs, /gt0)
harm2 = widget_info(asw_getctrl('HARM2'), /BUTTON_SET)
mapme_widget_magfield_harms, p, freqs, harm2, 2, '0000ff'x 
harm3 = widget_info(asw_getctrl('HARM3'), /BUTTON_SET)
mapme_widget_magfield_harms, p, freqs, harm3, 3, '00ff00'x 
harm4 = widget_info(asw_getctrl('HARM4'), /BUTTON_SET)
mapme_widget_magfield_harms, p, freqs, harm4, 4, 'ff0000'x 

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

gxbox = global['gxbox']
pos = global['curr_height']

step = gxbox.dr[0]*wcs_rsun()*1e-3
s = string(round(step*pos/1d3*1d2)/1d2, format = '(%"%6.2f")') 
asw_control, 'HEIGHT_MM', SET_VALUE = s
s = '[' + asu_compstr(round(local['bz_min', p])) + ' ... ' + asu_compstr(round(local['bz_max', p])) + ']' 
asw_control, 'BZ_RANGE', SET_VALUE = s
s = asu_compstr(round(local['babs_max', p])) 
asw_control, 'BABS_MAX', SET_VALUE = s

end

;-------------------------------------------------------
pro mapme_widget_get_3D_data, winsize, data, ind_scaled, common_scaled, mins = mins, maxs = maxs, minval = minval
compile_opt idl2

res = asu_get_data_keep_ratio(winsize, data, minval = minval)

mm = minmax(res)   
common_scaled = (res - mm[0])/(mm[1] - mm[0]) * 255d
ind_scaled = res
sz = size(res)
mins = dblarr(sz[3])
maxs = dblarr(sz[3])
for k = 0, sz[3]-1 do begin
    mins[k] = min(res[*, *, k])
    maxs[k] = max(res[*, *, k])
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
if ~keyword_set(box) then begin
    result = DIALOG_MESSAGE('Selected file does not contain magnetic field information.', title = 'MapMe Error', /ERROR)
    return
end

global['gxbox'] = box
t = box.index.date_obs
t = str_replace(t, 'T', ' ')
asw_control, 'MFDATETIME', SET_VALUE = t

asu_box_get_coord, box, boxdata

lon = round(boxdata.lon_cen)
lonl = lon lt 0 ? 'E' : 'W'
lat = round(boxdata.lat_cen)
latl = lat lt 0 ? 'S' : 'N'
pos = lonl + string(abs(lon), format='(%"%02d")') + ' ' + latl + string(abs(lat), format='(%"%02d")')  
asw_control, 'MFCENTER', SET_VALUE = pos

sz = size(box.bz)
s = string(sz[1], format='(%"%d")') + ' x ' + string(sz[2], format='(%"%d")') + ' (x ' + string(sz[3], format='(%"%d")') + ')'
asw_control, 'MFSIZE', SET_VALUE = s

asu_get_par_keep_ratio, global['winsize'], sz[1:2], newsize, coef, win_range, dat_range, x = x, y = y
local['b_x'] = x 
local['b_y'] = y 

mapme_widget_get_3D_data, global['winsize'], box.bz, ind, comm, mins = mins, maxs = maxs
local['bz_ind'] = ind 
local['bz'] = comm 
local['bz_min'] = mins 
local['bz_max'] = maxs 
local['babs_val'] = sqrt(box.bx^2 + box.by^2 + box.bz^2)
mapme_widget_get_3D_data, global['winsize'], local['babs_val'], ind, comm, maxs = maxs, minval = 0d
local['babs_ind'] = ind 
local['babs'] = comm 
local['babs_max'] = maxs 

model_mask = decompose(box.base.bz, box.base.ic)
local['b_mask'] = model_mask

model_mask[0, 0] = 1
model_mask[0, 1] = 7

mask = bytscl(asu_get_data_keep_ratio(global['winsize'], model_mask))
local['byte_mask'] = mask

mask = bytscl(asu_get_data_keep_ratio(global['winsize_c'], model_mask))
local['byte_mask_c'] = mask

cont = bytscl(asu_get_data_keep_ratio(global['winsize'], box.base.ic))
local['byte_cont'] = cont

asw_control, 'BSLIDE', SET_SLIDER_MIN = 0
asw_control, 'BSLIDE', SET_SLIDER_MAX = sz[3]-1
global['curr_height'] = 0
asw_control, 'BSLIDE', SET_VALUE = global['curr_height']

mapme_widget_update_mf_draw
mapme_widget_update_slider

end
