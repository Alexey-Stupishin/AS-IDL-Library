function gx_box_jsoc_get_content, t, dataset, segment, index, data, cache_dir = cache_dir, loc_file = loc_file, time_window = time_window

if not keyword_set(cache_dir) then cache_dir = GETENV('IDL_TMPDIR') 
if not keyword_set(time_window) then time_window = 720d

t1 = t - time_window / 2d
t2 = t + time_window / 2d

loc_file = gx_box_jsoc_get_fits_as(anytim(t1), anytim(t2), dataset, segment, cache_dir)

if strlen(loc_file) eq 0 then return, -1

read_sdo_silent, loc_file, index, data 

end
