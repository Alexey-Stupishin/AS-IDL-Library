;-------------------------------------------------------------------------
pro mapme_widget_calculate_event_slide, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local

if local['FluxR'] eq !NULL || local['FluxL'] eq !NULL then return

asw_control, 'RSLIDE', GET_VALUE = pos
global['curr_freq'] = pos

mapme_widget_calculate

end

;-------------------------------------------------------------------------
pro mapme_widget_calculate_freq_import, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

end

;-------------------------------------------------------------------------
pro mapme_widget_calculate_calc, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local

if global['gxbox'] eq !NULL then return 

atm = global['atm_model']
active = 0
max_h = 0
for k = 1, 7 do begin
    if atm[k].used then begin
        active++
        max_h = max_h > n_elements(atm[k].H) 
    endif     
endfor    

active = 7 ; NB!

Lmask = lonarr(active)
masksN = lonarr(active)
H = dblarr(active, max_h)
temp = dblarr(active, max_h)
dens = dblarr(active, max_h)
pos = 0
for k = 1, 7 do begin
    p = atm[k].used ? k : 1
    n = n_elements(atm[p].H)
    H[pos, 0:(n-1)] = atm[p].H *1d8
    temp[pos, 0:(n-1)] = atm[p].temp 
    dens[pos, 0:(n-1)] = atm[p].dens 
    Lmask[pos] = n
    masksN[pos] = k
    pos++
endfor    

as_range = widget_info(asw_getctrl('FR_RANGE'), /BUTTON_SET)
if as_range then begin
    asw_control, 'FR_RANGE_DATA', GET_VALUE = srange
    range = asu_parse_list(srange, /gt0)
    steps = round((range[1] - range[0])/range[2]) + 1
    freqs = indgen(steps, /double)*range[2] + range[0]
endif else begin
    asw_control, 'FR_LIST_DATA', GET_VALUE = sfreqs
    freqs = asu_parse_list(sfreqs, /gt0)
endelse

asw_control, 'VIS_STEP', GET_VALUE = visstep
asw_control, 'POS_ANGLE', GET_VALUE = posangle

freefree = widget_info(asw_getctrl('FREEFREE'), /BUTTON_SET)
qt = widget_info(asw_getctrl('QT'), /BUTTON_SET)

ptr = reo_prepare_calc_map(global['gxbox'], visstep, M, base, posangle = posangle $
                         , freefree = freefree, useqt = qt $
                         , arcbox = arcbox, version_info = version_info)

local['reo_ptr'] = ptr

; NB! check params
;;;; rc = reo_set_atmosphere_mask(local['reo_ptr'], H, temp, dens, Lmask, masksN, local['b_mask'])

FluxRW = dblarr(M[0], M[1], n_elements(freqs))
FluxLW = dblarr(M[0], M[1], n_elements(freqs))
ScanRW = dblarr(M[0], n_elements(freqs))
ScanLW = dblarr(M[0], n_elements(freqs))

WIDGET_CONTROL, /HOURGLASS

for k = 0, n_elements(freqs)-1 do begin     
    rc = reo_calculate_map_atm(local['reo_ptr'], freqs[k] * 1e9 $
                              , depthR = depthR, FluxR = FluxR, tauR = tauR, heightsR = heightsR, fluxesR = fluxesR, sR = sR $
                              , depthL = depthL, FluxL = FluxL, tauL = tauL, heightsL = heightsL, fluxesL = fluxesL, sL = sL $
                              , scanR = scanR, scanL = scanL $
                              , rc = rc)
    FluxRW[*, *, k] = FluxR                              
    FluxLW[*, *, k] = FluxL                              
    ScanRW[*, k] = ScanR                              
    ScanLW[*, k] = ScanL                              
endfor

rc = reo_uninit(local['reo_ptr'])

local['FluxR'] = FluxRW
local['FluxL'] = FluxLW
local['ScanR'] = ScanRW
local['ScanL'] = ScanLW
global['calc_freqs'] = freqs
global['curr_freq'] = 0
asw_control, 'RSLIDE', SET_SLIDER_MIN = 0
asw_control, 'RSLIDE', SET_SLIDER_MAX = n_elements(freqs)-1
asw_control, 'RSLIDE', SET_VALUE = global['curr_freq']
                              
mapme_widget_calculate

end

;-------------------------------------------------------------------------
pro mapme_widget_calculate
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if local['FluxR'] eq !NULL || local['FluxL'] eq !NULL then return

fluxR = bytscl(asu_get_data_keep_ratio(global['winsize'], local['FluxR', *, *, global['curr_freq']]))
fluxL = bytscl(asu_get_data_keep_ratio(global['winsize'], local['FluxL', *, *, global['curr_freq']]))

asw_control, 'RIGHT', GET_VALUE = drawID
WSET, drawID
device, decomposed = 0
loadct, 0, /silent
asu_tvplot, fluxR 

asw_control, 'LEFT', GET_VALUE = drawID
WSET, drawID
device, decomposed = 0
loadct, 0, /silent
asu_tvplot, fluxL
 
end
