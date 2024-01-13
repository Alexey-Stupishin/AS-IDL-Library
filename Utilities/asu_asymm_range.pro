function asu_asymm_range, data, no_background = no_background, no_topvalue = no_topvalue
compile_opt idl2

mm_data = double(minmax(data))

back = n_elements(no_background) eq 0 ? 1 : 0
top = n_elements(no_topvalue) eq 0 ? 1 : 0
cdelta = (mm_data[1] - mm_data[0])/float(255-back-top)
if back eq 1 then mm_data[0] -= cdelta
if top eq 1 then mm_data[1] += cdelta

return, mm_data

end
