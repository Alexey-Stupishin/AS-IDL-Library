;----------------------------------------------------------
function gyrosync_sketch_get_DulkMarsh, freqs, B, theta, N, L, deltaE, tau = tau, Temp = Temp
compile_opt idl2

fB = 2.699d6*B
ffB = freqs/fB

ibn = 3.3e-24 * 10^(-0.52*deltaE) * sin(theta*!DTOR)^(-0.43+0.65*deltaE) * ffb^(1.22-0.9*deltaE)
kbn = 1.4e-9 * 10^(-0.22*deltaE) * sin(theta*!DTOR)^(-0.09+0.72*deltaE) * ffb^(-1.3-0.98*deltaE)

S = ibn/kbn * B^2
tau = kbn/B*N*L ; * double((deltaE-2))/(deltaE-1)*0.5

F = S*(1 - exp(-tau))

Temp = 6.513d36 * F / freqs^2;

return, F

; Teff

end

;----------------------------------------------------------
function gyrosync_sketch_get_value, slider, data, linear = linear
compile_opt idl2
common G_ASU_GYROSYNC_SKETCH, global

gss_control, slider, GET_VALUE = pos
lims = global[data]

if n_elements(linear) eq 0 then lims = alog(lims)

v = pos/100d * (lims[1]-lims[0]) + lims[0]

if n_elements(linear) eq 0 then v = exp(v)

return, v

end

;----------------------------------------------------------
pro gyrosync_sketch_update
compile_opt idl2
common G_ASU_GYROSYNC_SKETCH, global

B = gyrosync_sketch_get_value('SLIDEB', 'B')
Th = gyrosync_sketch_get_value('SLIDETH', 'Th', /linear)
N = gyrosync_sketch_get_value('SLIDEN', 'N')
L = gyrosync_sketch_get_value('SLIDEL', 'L')
de = gyrosync_sketch_get_value('SLIDED', 'de', /linear)

gss_control, 'B', SET_VALUE = string(B, FORMAT = '(%"%4.0f")')
gss_control, 'TH', SET_VALUE = string(Th, FORMAT = '(%"%3.0f")')
gss_control, 'N', SET_VALUE = string(N, FORMAT = '(%"%8.1e")')
gss_control, 'L', SET_VALUE = string(L, FORMAT = '(%"%8.1e")')
gss_control, 'D', SET_VALUE = string(de, FORMAT = '(%"%5.1f")')

;min_freq = 10 * 2.699e6*B 
min_freq = 1e9
max_freq = 2e10
xrange = [min_freq, max_freq]

freqs = linspace(min_freq, max_freq, 1000)

F = gyrosync_sketch_get_DulkMarsh(freqs, B, Th, N, L, de, tau = tau, Temp = Temp)
;idx = where(tau lt 0.01, count)
;if count gt 0 then tau[idx] = 0.01
;idx = where(tau gt 100, count)
;if count gt 0 then tau[idx] = 100

gss_control, 'SPECTRA', GET_VALUE = fluxID
WSET, fluxID
!P.FONT = 1
device, decomposed = 0, set_font = 'Helvetica*32'
loadct, 0, /silent
plot, freqs, F, xrange = xrange, /ylog, yrange = [1e-12, 1e-7] ; , color = 100

gss_control, 'TEMP', GET_VALUE = tempID
WSET, tempID
!P.FONT = 1
device, decomposed = 0, set_font = 'Helvetica*32'
loadct, 0, /silent
plot, freqs, Temp, xrange = xrange, /ylog, yrange = [1e5, 1e10] ; , yrange = [0, 5e-8], color = 100

gss_control, 'TAU', GET_VALUE = tauID
WSET, tauID
!P.FONT = 1
device, decomposed = 0, set_font = 'Helvetica*32'
loadct, 0, /silent
plot, freqs, tau, xrange = xrange, /ylog, ystyle = 1, yrange = [0.01, 100] ; , color = 100

end

;----------------------------------------------------------
pro gss_control, uname, _ref_extra = _ref_extra
compile_opt idl2
common G_ASU_GYROSYNC_SKETCH, global

widg = widget_info(global['widbase'], find_by_uname = uname)
widget_control, widg, _extra = _ref_extra

end

;----------------------------------------------------------------------------------
pro gyrosync_sketch_buttons_event, event
compile_opt idl2
common G_ASU_GYROSYNC_SKETCH, global

if (tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST') then begin
    widget_control, event.top, /destroy
    return
endif

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

case eventval of
    'SLIDEB' : gyrosync_sketch_update
    'SLIDETH' : gyrosync_sketch_update
    'SLIDEN' : gyrosync_sketch_update
    'SLIDEL' : gyrosync_sketch_update
    'SLIDED' : gyrosync_sketch_update
endcase

end

;----------------------------------------------------------
pro gyrosync_sketch
compile_opt idl2
common G_ASU_GYROSYNC_SKETCH, global
global = hash()

winsize = [800, 250]
labsize = 60
valsize = 60
slidesize = winsize[0] - labsize - valsize

B = [150, 300]
Th = [45, 75]
N = [1e7, 1e8]
L = [1e5, 1e11]
de = [2.5, 4]
global['B'] = B
global['Th'] = Th
global['N'] = N
global['L'] = L
global['de'] = de

base = WIDGET_BASE(TITLE = 'Gyrosynchro Sketch', UNAME = 'GYROSYNC', /column, /TLB_KILL_REQUEST_EVENTS)
global['widbase'] = base

;mainrow = WIDGET_BASE(base, /row)
spectra = WIDGET_DRAW(base, GRAPHICS_LEVEL = 0, UNAME = 'SPECTRA', UVALUE = 'SPECTRA', XSIZE = winsize[0], YSIZE = winsize[1]) ; , /BUTTON_EVENTS)
temp =    WIDGET_DRAW(base, GRAPHICS_LEVEL = 0, UNAME = 'TEMP', UVALUE = 'TEMP', XSIZE = winsize[0], YSIZE = winsize[1]) ; , /BUTTON_EVENTS)
tau =     WIDGET_DRAW(base, GRAPHICS_LEVEL = 0, UNAME = 'TAU', UVALUE = 'TAU', XSIZE = winsize[0], YSIZE = winsize[1]) ; , /BUTTON_EVENTS)

Brow = WIDGET_BASE(base, /row)
    dummy = WIDGET_LABEL(Brow, VALUE = 'B: ', XSIZE = labsize)
    BLab = WIDGET_LABEL(Brow, VALUE = '', XSIZE = valsize, UNAME = 'B', UVALUE = 'B')
    BSlide = WIDGET_SLIDER(Brow, VALUE = 0, UNAME = 'SLIDEB', UVALUE = 'SLIDEB', XSIZE = slidesize, /SUPPRESS_VALUE)
Trow = WIDGET_BASE(base, /row)
    dummy = WIDGET_LABEL(Trow, VALUE = 'Theta: ', XSIZE = labsize)
    ThLab = WIDGET_LABEL(Trow, VALUE = '', XSIZE = valsize, UNAME = 'TH', UVALUE = 'TH')
    ThSlide = WIDGET_SLIDER(Trow, VALUE = 0, UNAME = 'SLIDETH', UVALUE = 'SLIDETH', XSIZE = slidesize, /SUPPRESS_VALUE)
Nrow = WIDGET_BASE(base, /row)
    dummy = WIDGET_LABEL(Nrow, VALUE = 'N: ', XSIZE = labsize)
    NLab = WIDGET_LABEL(Nrow, VALUE = '', XSIZE = valsize, UNAME = 'N', UVALUE = 'N')
    NSlide = WIDGET_SLIDER(Nrow, VALUE = 0, UNAME = 'SLIDEN', UVALUE = 'SLIDEN', XSIZE = slidesize, /SUPPRESS_VALUE)
Lrow = WIDGET_BASE(base, /row)
    dummy = WIDGET_LABEL(Lrow, VALUE = 'L: ', XSIZE = labsize)
    LLab = WIDGET_LABEL(Lrow, VALUE = '', XSIZE = valsize, UNAME = 'L', UVALUE = 'L')
    LSlide = WIDGET_SLIDER(Lrow, VALUE = 0, UNAME = 'SLIDEL', UVALUE = 'SLIDEL', XSIZE = slidesize, /SUPPRESS_VALUE)
drow = WIDGET_BASE(base, /row)
    dummy = WIDGET_LABEL(drow, VALUE = 'delta: ', XSIZE = labsize)
    dLab = WIDGET_LABEL(drow, VALUE = '', XSIZE = valsize, UNAME = 'D', UVALUE = 'D')
    dSlide = WIDGET_SLIDER(drow, VALUE = 0, UNAME = 'SLIDED', UVALUE = 'SLIDED', XSIZE = slidesize, /SUPPRESS_VALUE)

WIDGET_CONTROL, base, /REALIZE
XMANAGER, 'gyrosync_sketch_buttons', base, GROUP_LEADER = GROUP, /NO_BLOCK

gyrosync_sketch_update

end
