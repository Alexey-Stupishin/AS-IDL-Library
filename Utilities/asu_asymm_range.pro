function asu_asymm_range, data, n_colors = n_colors, ct_minmax = ct_minmax, no_background = no_background, no_topvalue = no_topvalue
compile_opt idl2

mm_data = double(n_elements(ct_minmax) eq 0 ? minmax(data) : ct_minmax)

back = n_elements(no_background) eq 0 ? 1 : 0
top = n_elements(no_topvalue) eq 0 ? 1 : 0
cdelta = (mm_data[1] - mm_data[0])/float(255-back-top)
if back eq 1 then mm_data[0] -= cdelta
if top eq 1 then mm_data[1] += cdelta
if n_elements(n_colors) ne 0 then begin
    ndelta = (mm_data[1] - mm_data[0])/n_colors/2d
    mm_data[0] -= ndelta
    mm_data[1] += ndelta
endif

return, mm_data

end
