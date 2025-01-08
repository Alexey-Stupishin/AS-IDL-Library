function aia_download_get_query, wave, tstart, tstop, urls, filenames, vso = vso

filenames = !NULL
urls = !NULL
if keyword_set(vso) then begin
    vv = obj_new('vso')
    s = vv->buildQuery(anytim(tstart, /ccsds), anytim(tstop, /ccsds), wave = wave, extent = 'FULLDISK', source = 'SDO', INSTRUMENT = 'aia')
    stack   = vv->query(s)
    meta    = stack->contents()
    if meta ne !NULL then begin
        records = vv->getdata(meta)
        urls    = records.url
        if n_elements(urls) gt 0 then begin
            filenames = aia_utils_get_vso_filename(meta)
            code = 0
        endif else begin
            code = -2
        endelse
    endif else begin
        code = -1
    endelse
    obj_destroy, vv
endif else begin
    ds = ssw_jsoc_wave2ds(wave)
    time_query =  ssw_jsoc_time2query(tstart, tstop)
    query = ds+'['+time_query+']'+'['+strcompress(wave, /remove_all)+']'
    query = query[0]
    urls = ssw_jsoc_query2sums(query,/urls)
    if n_elements(urls) gt 0 then begin
        index = ssw_jsoc(ds = query,/rs_list,/xquery)
        filenames = ssw_jsoc_index2filenames(index)
        code = 0
    endif else begin
        code = -2
    endelse
end

return, code

end
