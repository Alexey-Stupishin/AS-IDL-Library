function asu_symm_range, data, no_background = no_background, no_topvalue = no_topvalue
compile_opt idl2

max_data = double(max(abs(data)))
mm_data = [-max_data, max_data]

back = n_elements(no_background) eq 0 ? 1 : 0
top = n_elements(no_topvalue) eq 0 ? 1 : 0
cdelta = 2d*max_data/float(255-back-top)
if back eq 1 then mm_data[0] -= cdelta
if top eq 1 then mm_data[1] += cdelta

return, mm_data

end
