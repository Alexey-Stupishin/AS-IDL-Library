pro aia_download_get_query, wave, tstart, tstop, urls, filenames, vso = vso

if keyword_set(vso) then begin
    vv = obj_new('vso')
    s = vv->buildQuery(anytim(tstart, /ccsds), anytim(tstop, /ccsds), wave = wave, extent = 'FULLDISK', source = 'SDO', INSTRUMENT = 'aia')
    stack   = vv->query(s)
    meta    = stack->contents()
    records = vv->getdata(meta)
    urls    = records.url
    filenames = aia_utils_get_vso_filename(meta)
    obj_destroy, vv
endif else begin
    ds = ssw_jsoc_wave2ds(wave)
    time_query =  ssw_jsoc_time2query(tstart, tstop)
    query = ds+'['+time_query+']'+'['+strcompress(wave, /remove_all)+']'
    query = query[0]
    urls = ssw_jsoc_query2sums(query,/urls)
    index = ssw_jsoc(ds = query,/rs_list,/xquery)
    filenames = ssw_jsoc_index2filenames(index)
end

end
