function asu_jsoc_get_fits, qtime, twin, ds, segment, compr_dir, save_dir, wave = wave, err = err

t = anytim(qtime)
t1 = t-twin/2
t2 = t+twin/2  
  
ssw_jsoc_time2data_silent, t1, t2, index, urls, /urls_only, /silent, ds=ds, segment=segment, wave=wave, count = count
  
err = ''  
if n_elements(urls) eq 0 then begin
    err = 'No data for ds = "' + ds + '" at ' + qtime
    if keyword_set(wave) then err += ', wave = ' + strtrim(wave,2)
    print, err
    return, ''
endif
  
query = ssw_jsoc_time2query(t1, t2, ds = ds)
if keyword_set(wave) then query += '[' + strtrim(wave,2) + ']'
query += '{' + segment + '}'
  
times_str = str_replace(strmid((index.t_obs),0,10),'.','-') + strmid((index.t_obs),10)
t_found =anytim(times_str)
foo = min(abs(t - t_found), ind)
  
index = index[ind]
url  = urls[ind]
time_s = strreplace(index.t_rec,'.','')
time_s = strreplace(time_s,':','')
local_file = ds+'.'+time_S+'.'+segment
if keyword_set(wave) then begin
    local_file += '.'+wave
endif
local_file += '.fits'
;local_file = ssw_jsoc_index2filenames(index)
uncomp_file = save_dir + path_sep() + local_file

info = file_info(uncomp_file, /NOEXPAND_PATH)
if info.exists then begin
    print, uncomp_file+" is already present"
    return, uncomp_file
endif

tmp_file = compr_dir + path_sep() + local_file
  
status = asu_try_download(url, tmp_file)

read_sdo_silent, tmp_file, index, data, /use_shared, /uncomp_delete, /hide, /silent
writefits_silent, uncomp_file, float(data), struct2fitshead(index)     

file_delete, tmp_file

return, uncomp_file
  
end
