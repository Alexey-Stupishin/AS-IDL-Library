function asu_symm_range, data, no_background = no_background
compile_opt idl2

max_data = double(max(abs(data)))
mm_data = [-max_data, max_data]

if n_elements(no_background) eq 0 then mm_data[0] -= max_data/127d 

return, mm_data

end
