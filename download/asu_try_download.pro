function asu_try_download, url, outfile, tries = tries, timeout = timeout, postponed = postponed

if ~keyword_set(timeout) then timeout = 3
if ~keyword_set(tries) then tries = 3

for itry = 1, tries do begin
    sock_get, url, outfile, status = status, /quiet
    if status eq 0 then begin
        print, outfile + ": Downloading failed (" + strcompress(itry) + ")"
        if itry lt tries then wait, timeout
    endif else begin
        break
    endelse    
endfor

if status eq 0 then begin
    print, outfile + ": cannot download!"
    if keyword_set(postponed) then postponed.Add, {url:url, outfile:outfile}
endif
if status eq 1 then print, outfile+" downloaded succesfully"
if status eq 2 then print, outfile+" is already present"

return, status

end
