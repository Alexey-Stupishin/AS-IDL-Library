function gx_box_jsoc_make_query_as,t1,t2,ds,segment, waves = waves

query = ssw_jsoc_time2query(t1, t2, ds=ds)
if keyword_set(waves) then query=query+'['+arr2str(strtrim(waves,2))+']'
query=query+'{'+segment+'}'
return, query[0]
    
end

;----------------------------------------------------------------------------
function gx_box_jsoc_make_filename_as, index, ds, segment, wave = wave
  
time_s = strreplace(index.t_rec,'.','')
time_s = strreplace(time_s,':','')
  
if keyword_set(wave) then begin
    file = ds+'.'+time_s+'.'+segment+'.'+wave+'.fits'
endif else begin
    file = ds+'.'+time_s+'.'+segment+'.fits'
endelse

return, file
  
end

;----------------------------------------------------------------------------
function gx_box_jsoc_try_cache_as, dir, query, index, ds, segment, wave = wave

if not file_test(dir) then file_mkdir,dir
index_file = filepath('index_as.sav', root = dir)

try_query = 0
if not file_test(index_file) then begin
    queries = []
    files = []
    save, queries, files, file = index_file
endif

full_file = ''
restore, index_file
if n_elements(queries) gt 0 then begin
    ind = where(queries eq query, count)
    if count gt 0 then begin ; query in the index file
        ind = ind[0]
        file = files[ind]
        full_file = dir + path_sep() + file
        if not file_test(dir + path_sep() + file) then begin 
            ; file is not found in cache, but query in the index
            ; - file was deleted?
            indrest = where(queries ne query) ; all other queries
            if indrest[0] eq -1 then begin
                queries = []
                files = []
                save, queries, files, file = index_file
            endif
            ; refresh index (remove this query/file)
            queries = queries[indrest]
            files = files[indrest]
            save, queries, files, file = index_file
        endif else begin ; query/file is in index
            try_query = 1
        endelse
    endif    
endif

if file_test(full_file) && try_query then return, full_file

; no query/file in index
local_dir = str_replace(strmid((index.t_obs),0,10),'.','-')
local_file = local_dir + path_sep() + gx_box_jsoc_make_filename_as(index, ds, segment, wave = wave)

fullfile = dir + path_sep() + local_file
if file_test(fullfile) then begin
    needsave = 0 
    if n_elements(queries) gt 0 then begin
        ind = where(queries eq query, count)
        if count eq 0 then needsave = 1 
    endif else begin
        needsave = 1
    endelse
    if needsave then begin    
        queries = [queries, query]
        files = [files, local_file]
        save, queries, files, file = index_file
    endif
    return, fullfile
endif

return, ''

end

;----------------------------------------------------------------------------
pro gx_box_jsoc_save2cache_as, dir, query, data, index, file

index_file = filepath('index_as.sav', root = dir)
if not file_test(dir) then file_mkdir,dir
If not file_test(index_file) then begin
    queries = []
    files = []
endif else restore, index_file
if n_elements(queries) eq 0 then begin
    queries = []
    files = [] 
endif
  
date_dir = anytim(strreplace(index.t_rec,'.','-'),/ccsds,/date)
file_mkdir,filepath( date_dir, root = dir)
  
local_file = date_dir + path_sep() + file
full_file = filepath(file, subdir = date_dir, root = dir)
  
writefits, full_file, data, struct2fitshead(index)
  
needsave = 0 
if n_elements(queries) gt 0 then begin
    ind = where(queries eq query, count)
    if count eq 0 then needsave = 1 
endif else begin
    needsave = 1
endelse
if needsave then begin    
    queries = [queries, query]
    files = [files, local_file]
    save, queries, files, file = index_file
endif
  
end

;----------------------------------------------------------------------------
function gx_box_jsoc_get_fits_as, t1, t2, ds, segment, cache_dir, wave = wave

query = gx_box_jsoc_make_query_as(t1, t2, ds, segment, wave = wave)
ssw_jsoc_time2data, t1, t2, index, urls, /urls_only, ds=ds, segment = segment, wave = wave, count = count
if n_elements(index) eq 0 then begin
    s = 'can not get urls/index for ds ="' + ds + '"'
    if n_elements(wave) gt 0 then s += ' and wave = ' + strcompress(wave)
    message, s, /info
    message, 'execution terminated', /info
    return , ''
endif
  
local_file = gx_box_jsoc_try_cache_as(cache_dir, query, index, ds, segment, wave = wave)
  
if local_file ne '' then return, local_file
  
if n_elements(urls) eq 0 then begin
    s = 'can not download data for ds ="' + ds + '"'
    if n_elements(wave) gt 0 then s += ' and wave = ' + strcompress(wave)
    message, s, /info
    message, 'execution terminated', /info
    return , ''
endif
  
t_request = (anytim(t1) + anytim(t2))*.5
times_str = str_replace(strmid((index.t_obs),0,10),'.','-') + strmid((index.t_obs),10)
t_found = anytim(times_str) ; anytim(index.t_obs)
foo = min(abs(t_request - t_found), ind)
  
index = index[ind]
url  = urls[ind] 
local_file = gx_box_jsoc_make_filename_as(index, ds, segment,wave = wave)
tmp_dir = GETENV('IDL_TMPDIR')
tmp_file = filepath(local_file, /tmp)
  
sock_copy, url, tmp_file
read_sdo, tmp_file, tmp_index, data, /uncomp_delete
file_delete, tmp_file
  
gx_box_jsoc_save2cache_as, cache_dir, query, data, index, file_basename(local_file)
return, gx_box_jsoc_try_cache_as(cache_dir, query) ; just to be sure
  
end
