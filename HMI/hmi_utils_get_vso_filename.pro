function hmi_utils_get_vso_filename, metas, dataset

n = n_elements(metas)

;;;; hmi.ic_45s.2015.01.01_00_00_45_TAI.continuum.fits
;;;; hmi.m_45s.2015.01.01_00_00_45_TAI.magnetogram.fits

; hmi.M_45s_mod.20160428_100819_TAI.2.magnetogram

; fileid = 'hmi__ic_45s:15427201:15427201'
; time = '2014-12-31T23:59:39'

filenames = strarr(n)
for k = 0, n-1 do begin
    meta = metas[k]
    
    t = meta.time.start ; '2023-01-01T00:00:09'
    t = str_replace(t, '-', '')
    t = str_replace(t, 'T', '_')
    t = str_replace(t, ':', '')
    
    signature = dataset eq 'continuum' ? 'Ic' : 'M'
    
    filenames[k] = 'hmi.' + signature + '_45s.' + t + '.' + dataset + '.fits'
endfor

return, filenames

end
 