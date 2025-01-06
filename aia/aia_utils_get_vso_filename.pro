function aia_utils_get_vso_filename, metas

n = n_elements(metas)

filenames = strarr(n)
for k = 0, n-1 do begin
    meta = metas[k]
    fid = meta.fileid
    parse = stregex(fid,'aia__(.*):(.*):.*',/subexpr,/extract) ; 'aia__lev1:171:1451606435'
    
    t = meta.time.start ; '2023-01-01T00:00:09'
    t = str_replace(t, ':', '')
    
    signature = '_euv_12s.'
    wavelng = parse[2]
    if fix(wavelng) gt 1000 then signature = '_uv_24s.'
    
    filenames[k] = 'aia.' + parse[1] + signature + t + 'Z.image.' + wavelng + '.fits'; aia.lev1_euv_12s.2018-09-30T085947Z.image.171
endfor

return, filenames

end
 