function asu_get_data_keep_ratio, winsize, data, minval = minval
compile_opt idl2

sz = size(data)
if sz[0] lt 3 then sz[3] = 1

asu_get_par_keep_ratio, winsize, sz[1:2], newsize, coef, win_range, dat_range

base = dblarr(winsize[0], winsize[1], sz[3])
for k = 0, sz[3]-1 do begin
    base[*, *, k] = n_elements(minval) ne 0 ? minval : min(data[*, *, k])
    res = bilinear(data[dat_range[0, 0]:dat_range[0, 1], dat_range[1, 0]:dat_range[1, 1], k], indgen(newsize[0])*coef, indgen(newsize[1])*coef)
    base[win_range[0, 0]:win_range[0, 1], win_range[1, 0]:win_range[1, 1], k] = res
endfor
    
return, base   

end
