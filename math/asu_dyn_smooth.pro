function asu_dyn_smooth, scan, half_slit_vert, half_slit_horz, method = method

resolve_routine,'asu_dyn_smooth_m1',/compile_full_file, /either
resolve_routine,'asu_dyn_smooth_m2',/compile_full_file, /either

if n_elements(method) eq 0 then method = 1
mfunc = method eq 1 ? 'asu_dyn_smooth_m1' : 'asu_dyn_smooth_m2'

return, call_function(mfunc, scan, half_slit_vert, half_slit_horz)

end
 