function hmi_utils_dowload_vso, t1, t2, dataset, cache_dir, first = first

vv = obj_new('vso')
s = vv->buildQuery(anytim(t1, /ccsds), anytim(t2, /ccsds), extent = 'FULLDISK', source = 'SDO', INSTRUMENT = 'HMI')
stack   = vv->query(s)
meta    = stack->contents()
if meta ne !NULL then begin
    records = vv->getdata(meta)
    urls    = records.url
    if n_elements(urls) gt 0 then begin
        cnt = 0
        for k = 0, n_elements(urls)-1 do begin
            url = urls[k]
            ; ...series=hmi__Ic_45s...
            ; ...series=hmi__M_45s...
            parse = stregex(url, '.*series=hmi__(.*)_45s.*',/subexpr,/extract)
            if parse[1] eq '' then continue
            if parse[1] eq 'V' then continue
            if parse[1] eq 'Ic' && dataset ne 'continuum' then continue
            if parse[1] eq 'M' && dataset ne 'magnetogram' then continue
    
            filename = hmi_utils_get_vso_filename(meta[k], dataset)
            fullname = cache_dir + path_sep() + filename
            as_sock_get, url, fullname, status = status, /quiet, /no_rename
            if status eq 0 then begin
                message, /info, "Downloading " + filename + " failed"
                continue
            endif
    
            read_sdo_silent, fullname, index_in, data_in, /use_shared, /uncomp_delete, /hide, /silent
            writefits_silent, fullname, float(data_in), struct2fitshead(index_in)
            message, /info, 'Download ' + dataset + ' successful, output file = "' + fullname + '"'
            cnt++
    
            if keyword_set(first) then break
        endfor
    
        code = cnt
    endif else begin
        code = -2
    endelse
endif else begin
    code = -1
endelse

obj_destroy, vv
return, code

end