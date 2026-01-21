function asu_modify_LOS_gauss, h0, v0, h_center, width, h, v, factor = factor, value = value, np = np, min_factor = min_factor, log = log
compile_opt idl2

h = h0
v = v0

if n_elements(factor) eq 0 && n_elements(value) eq 0 then return, 0 
log = n_elements(log) eq 0 ? 0 : log ne 0
    
if log then v = alog(v)

v_center = interpol(v, h, h_center);
if n_elements(value) ne 0 then begin
    vv = value
    if log then vv = alog(vv)
    v_peak = vv - v_center
endif else begin
    v_peak = v_center*(factor - 1d)
endelse

if n_elements(np) eq 0 then np = 201
np = floor(np/2)*2 + 1

if n_elements(min_factor) eq 0 then min_factor = 1d-4

mu = 4d*alog(2d)/width^2
half_range = sqrt(-alog(min_factor)/mu); % in height units

left_h = h_center - half_range
right_h = h_center + half_range

left_idxs = where(h lt left_h, left_count)
right_idxs = where(h gt right_h, right_count)
if left_count eq 0 || right_count eq 0 then return, 0 
left_idx = max(left_idxs)
right_idx = min(right_idxs)

h_new = linspace(-half_range, half_range, np) + h_center
step = 2d*half_range/(np-1)

v_new = interpol(v, h, h_new)

h = [h[0:left_idx], h_new, h[right_idx:-1]]
v = [v[0:left_idx], v_new, v[right_idx:-1]]

gcenter = (np-1)/2d
v_add = dblarr(np)
for k = 0, np-1 do begin
    d_gauss = (gcenter - k)*step
    v_add[k] = v_peak * exp(-mu*(d_gauss)^2)
endfor

from = left_idx + 1
to = left_idx + np - 1
v[from:to] = v[from:to] + v_add

if log then v = exp(v)

return, 1

end
