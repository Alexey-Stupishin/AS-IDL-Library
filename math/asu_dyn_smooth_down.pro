function asu_dyn_smooth_down, scan, smoo, half_slit_vert, half_slit_horz, lim_top, lim_edge, method = method

idx = where(scan gt max(scan)*lim_top)
if n_elements(idx) eq 0 then return, smoo

scan_up = scan[idx]
smoo_up = smoo[idx]
excess = smoo_up/scan_up
downs = excess[where(excess gt 1.0)] 
if n_elements(downs) le 1 then return, smoo

hist = histogram(downs, NBINS = 10, LOCATIONS = edges)
cumsum = total(hist, /CUMULATIVE)
idx = where(cumsum ge total(hist)*lim_edge)
if n_elements(idx) eq 0 then return, smoo

smoo_down = smoo/edges[idx[0]]

idx = where(smoo_down gt scan)
smoo_down[idx] = scan[idx]

return, asu_dyn_smooth(smoo_down, half_slit_vert, half_slit_horz, method = method) 

end