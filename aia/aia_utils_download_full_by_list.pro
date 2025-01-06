pro aia_utils_download_full_by_list, list, waves, aia_dir, vso = vso

file_mkdir, aia_dir

if waves eq '' || waves eq !NULL then waves = ['94', '131', '171', '193', '211', '304', '335', '1600', '1700']

config = {tstart:0d, tstop:0d, timeout:1, count:1, limit:30, timeout_post:1, count_post:1}

for j = 0, n_elements(waves)-1 do begin
    dt = 6d
    if fix(waves[j]) gt 1000 then dt = 12d
    for k = 0, n_elements(list)-1 do begin
        config.tstart = anytim(list[k]) - dt
        config.tstop = config.tstart + 2*dt
        aia_download_by_config, waves[j], aia_dir, config, downlist = downlist, vso = vso, /down_message
        if downlist.Count() eq 0 then continue
        read_sdo_silent, downlist[0].filename, index_in, data_in, /use_shared, /uncomp_delete, /hide, /silent
        writefits_silent, downlist[0].filename, float(data_in), struct2fitshead(index_in)
    endfor    
endfor
    
end
