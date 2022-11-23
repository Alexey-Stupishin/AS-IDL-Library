pro reu_qs_get_scan, freq, T, R, step $ ; in
                   , steps, scan        ; out 
;
; Input:
;   freq - frequency [GHz]
;   T - temperature [K]
;   R - Solar radius [arcsec]
;   step - data step [arcsec]
;
; Output:
;   steps - position of scan points [arcsec]
;   scan - emulated RATAN scan [Jy/arcsec]
;

NR = 2*ceil(R/step)+1
sz = intarr(2)
sz[0] = 3*NR
sz[1] = NR

rmap = rtu_circle_map(sz, R/step)

basev = -R
steps = asu_linspace(-3*R, 3*R, sz[0])
rtu_create_ratan_diagrams, freq, sz, [step, step], [0, basev], diagrH, diagrV

fluxmap = asu_temp2intensity(rmap*T, freq*1d9) * step^2 * 2.35d8 *1d4

scan = rtu_map_convolve(fluxmap, diagrH, diagrV, [step, step])

out = floor(NR*0.9d)
from = out
to = n_elements(steps) - out - 1
steps = steps[from:to]
scan = scan[from:to]

end
