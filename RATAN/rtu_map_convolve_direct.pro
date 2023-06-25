function rtu_map_convolve_direct, freq, visstep, base, fluxmap, mode = mode, c = c, b = b
; visstep - parameter (see reo_prepare_calc_map), arcsec 
; base - calculated by reo_prepare_calc_map, arcsec
; fluxmap - calculated by reo_calculate_map (FluxR, FluxL), s.f.u.

steps = double([visstep, visstep])
sz = size(fluxmap)
rtu_create_ratan_diagrams, freq*1e-9, sz[1:2], steps, [0, base[1]], diagrH, diagrV, mode = mode, c = c, b = b
scan = rtu_map_convolve(fluxmap, diagrH, diagrV, steps)

return, scan

end
