function aia_download_by_config, wave, save_dir, config, dirmode = dirmode, down_message = down_message, downlist = downlist, vso = vso
compile_opt idl2

t0 = systime(/seconds)

delt = fix(wave) gt 1000 ? 12 : 6
ts = anytim(config.tstart)
te = anytim(config.tstop)
n_frames = (te-ts)/delt

t0 = systime(/seconds)
n_done = 0

outresult = 0 
if arg_present(downlist) ne 0 then begin
    outresult = 1
    downlist = list()
endif    

postponed = list()
post_n = 0

code = aia_download_get_query(wave, config.tstart, config.tstop, urls, filenames, vso = vso)
if code lt 0 then return, code
swave = strcompress(wave, /remove_all)

ccsds = anytim(config.tstart, /ccsds)
date = strmid(ccsds, 0, 4) + strmid(ccsds, 5, 2) + strmid(ccsds, 8, 2) 

foreach url, urls, j do begin
    time_download_started = systime(1)
    if keyword_set(down_message) then message, /info, "Wave " + swave + ": downloading "+filenames[j]+" from "+url+'...'
    
    ; date = asu_date_from_filename(filenames[j])
    
    if n_elements(dirmode) eq 0 || dirmode eq 'cache' then begin
        date_dir = save_dir + path_sep() + date
        wave_dir = date_dir + path_sep() + swave
        file_mkdir, wave_dir
    endif else begin
        wave_dir = save_dir
    endelse
        
    filename = wave_dir + path_sep() + filenames[j]
    
    for itry = 1, config.count do begin
        as_sock_get, url, filename, status = status, /quiet, /no_rename
        if status eq 0 then begin
            message, /info, "Downloading failed (" + strcompress(itry) + ")"
            if itry lt config.count then wait, config.timeout
        endif else begin
            break
        endelse    
    endfor

    if status eq 0 then begin
        if post_n gt config.limit then begin
            message, /info, "Too many downloads failed, rejected"
            return, -3
        endif else begin
            postponed.Add, {url:url, filename:filename}
        endelse    
        break
    endif else begin
        if outresult ne 0 then downlist.Add, {url:url, filename:filename}
        curr_time = systime(1)
        time_download = curr_time - time_download_started
        parse = stregex(filenames[j],'.*AIA(.*)',/subexpr,/extract)
        fname = 'AIA' + parse[1]
        remains = '...'
        if n_done gt 0 then begin
            part = double(n_done)/ n_frames
            passed = curr_time - t0
            est = passed/part
            rem = est-passed
            if rem lt 24*60*60 then remains = asu_sec2hms(rem, /issecs)
        endif
        if status eq 1 then message,/info, "Wave " + swave + ": " + fname + " downloaded succesfully in "+strcompress(time_download)+" seconds, est. remains " + remains
        if status eq 2 then message,/info, "Wave " + swave + ": " + fname + " is already present, est. remains " + remains
        
        n_done++
    endelse
endforeach

for j = 0, n_elements(postponed)-1 do begin
    url = postponed[j].url
    filename = postponed[j].filename
    for itry = 1, config.count_post do begin
        sock_get, url, filename, status = status
        if status eq 0 then begin
            message, /info, "Postponed downloading failed (" + strcompress(itry) + ")"
            if itry lt config.count_post then wait, config.timeout_post
        endif    
    endfor
    if status eq 0 then begin
        message, /info, "Postponed downloads failed, rejected"
        return, -4
    endif
    if status ne 0 && outresult ne 0 then downlist.Add, {url:url, filename:filename}
endfor

;message, strcompress(string(systime(/seconds)-t0,format="('download performed in ',g0,' seconds')")), /cont
message, 'download complete in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

return, 0
  
end

