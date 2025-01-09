pro hmi_utils_download_full_by_list, list, hmi_dir, n_segment = n_segment, dataset = dataset, vso = vso

if n_elements(dataset) eq 0 then dataset = 'magnetogram'

if keyword_set(vso) && ~(dataset eq 'magnetogram' || dataset eq 'continuum') then begin
    message, 'not correct dataset "' + dataset + '" for VSO source', /continue
    return
endif

if n_elements(n_segment) eq 0 then begin
    n_segment = keyword_set(vso) ? 45 : 720
endif

if ~keyword_set(vso) then begin
    case n_segment of
        720: begin
                segment = 'hmi.M_720s'
             end
         45: begin
                segment = 'hmi.M_45s'
             end
         else: begin
                message, 'wrong segment value: ' + strcompress(string(n_segment), /remove_all), /continue
                return
               end 
    endcase
endif

file_mkdir, hmi_dir
time_window = double(n_segment)

for k = 0, n_elements(list)-1 do begin
    t_ = anytim(list[k])
    t1 = t_ - time_window/2d
    t2 = t_ + time_window/2d
    if keyword_set(vso) then begin
        n_success = hmi_utils_dowload_vso(t1, t2, dataset, hmi_dir, /first)
        if n_success lt 0 then message, 'unsuccessful query, queried time = ' + anytim(t_, /ccsds) + ', code = ' + strcompress(string(n_success), /remove_all) + ' (' + asu_download_code_message(code) + ')', /continue else $
            if n_success eq 0 then message, 'No queried URLs, queried time = ' + anytim(t_, /ccsds), /continue
    endif else begin
        file = gx_box_jsoc_get_fits_as(t1, t2, segment, dataset, hmi_dir)
    endelse    
endfor

end
