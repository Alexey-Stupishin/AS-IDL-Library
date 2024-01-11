function asu_asymm_range, data, no_background = no_background
compile_opt idl2

mm_data = double(minmax(data))

if n_elements(no_background) eq 0 then mm_data[0] -= (mm_data[1] - mm_data[0])/254d

return, mm_data

end
