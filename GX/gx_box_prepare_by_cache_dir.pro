function gx_box_prepare_by_cache_dir, time, hmi_dir

hmi_files = !NULL

ds = [       'hmi.B_720s','hmi.B_720s','hmi.B_720s',  'hmi.B_720s','hmi.M_720s',   'hmi.Ic_noLimbDark_720s']
needFiles = ['field',     'azimuth',   'inclination', 'disambig',  'magnrtogram',  'continuum']

; find all 'field's
t = anytim(time)
field_files = file_search(filepath('*field.fits', root_dir = hmi_dir))
deltas = dblarr(n_elements(field_files))
for k = 0, n_elements(field_files)-1 do begin
    tt = asu_extract_time(field_files[k])
    deltas[k] = abs(t-tt)
endfor

dmin = min(deltas, im)
if dmin gt 2880 then return, !NULL

hmi_files = {field:'', inclination:'', azimuth:'', disambig:'', magnetogram:'', continuum:''}
tt = asu_extract_time(field_files[k], out_style = 'asu_time_short')
for i = 0, n_elements(ds)-1 do begin
    hmi_files.(i) = ds[i] + '.' + tt + '_TAI.' + needFiles[i] + '.fits' 
endfor

; AIA ?

end
    