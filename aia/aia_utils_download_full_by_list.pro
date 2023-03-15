pro aia_utils_download_full_by_list, list, waves, aia_dir

file_mkdir, aia_dir

config = {tstart:0d, tstop:0d, timeout:3, count:3, limit:30, timeout_post:5, count_post:3}

for j = 0, n_elements(waves)-1 do begin
    dt = 6d
    if fix(waves[j]) gt 1000 then dt = 12d
    for k = 0, n_elements(list)-1 do begin
        config.tstart = anytim(list[k]) - dt
        config.tstop = config.tstart + 2*dt
        aia_download_by_config, waves[j], aia_dir, config, downlist = downlist, /down_message
        if downlist.Count() eq 0 then continue
        read_sdo_silent, downlist[0].filename, index_in, data_in, /use_shared, /uncomp_delete, /hide, /silent
        writefits_silent, downlist[0].filename, float(data_in), struct2fitshead(index_in)
    endfor    
endfor
    
end
