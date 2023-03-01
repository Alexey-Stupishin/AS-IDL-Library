pro hmi_utils_download_full_by_list, list, hmi_dir, n_segment = n_segment, time_window = time_window

file_mkdir, hmi_dir

if n_elements(time_window) eq 0 then time_window  = 720d
if n_elements(n_segment) eq 0 then n_segment = 720

case n_segment of
    720: segment = 'hmi.M_720s'
     45: segment = 'hmi.M_45s'
   else: message, 'wrong segment value: ' + strcompress(string(n_segment), /remove_all)  
endcase

for k = 0, n_elements(list)-1 do begin
    t_ = anytim(list[k])
    t1 = t_ - time_window / 2d
    t2 = t_ + time_window / 2d
    file = gx_box_jsoc_get_fits_as(t1, t2, segment, 'magnetogram', hmi_dir)
endfor

end
