pro asu_selcopy, root, dest, exts, pattern = pattern, remove_pattern = remove_pattern

sources = file_search(filepath('*', root_dir = root))
if isa(sources, /scalar) && sources eq '' then return

foreach source, sources, i do begin
    f_inf = file_info(source)
    if f_inf.directory then begin 
        pos = strpos(source, path_sep(), /REVERSE_SEARCH)
        nextlev = strmid(source, pos+1)
        newdest = dest
        if n_elements(pattern) eq 0 || n_elements(remove_pattern) eq 0 || ~remove_pattern || nextlev ne pattern then begin
            newdest += path_sep() + nextlev
        endif
        asu_selcopy, source, newdest, exts, pattern = pattern, remove_pattern = remove_pattern
    endif else begin
        if n_elements(pattern) ne 0 then begin
            expr = stregex(source, '.*(' + pattern + ').*', /subexpr,/extract)
            if n_elements(expr) ne 2 || expr[1] ne pattern then begin
                stophere = 1
                continue
            endif    
        endif    
        found = 0
        for k = 0, n_elements(exts)-1 do begin
            lng = strlen(exts[k])
            if strmid(source, strlen(source) - strlen(exts[k])) eq exts[k] then begin
                found = 1
                break
            endif     
        endfor
        if found then begin
            file_mkdir, dest
            pos = strpos(source, path_sep(), /REVERSE_SEARCH)
            filename = strmid(source, pos+1)
            file_copy, source, dest + path_sep() + filename 
        end    
    endelse
endforeach

end
