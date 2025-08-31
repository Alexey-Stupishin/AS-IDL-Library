function sst_get_execute, box

s = 'gx_fov2box, ''' + strmid(box.index.date_obs, 0, 10) + ' ' + strmid(box.index.date_obs, 11, 8) + ''''
s = s + ', CENTER_ARCSEC=[' + string(box.index.crln_obs, FORMAT='(%"%7.2f")') + ', ' +  string(box.index.crlt_obs, FORMAT='(%"%7.2f")') + ']'
s = s + ', DX_KM=' + string(box.dr[0]*6.96d5, FORMAT='(%"%7.2f")')
s = s + ', EUV= 0, NLFFF_ONLY= 1, OUT_DIR=''C:\gx_models'''
sz = size(box.bx)
s = s + ', SIZE_PIX=[' + string(sz[1]) + ', ' + string(sz[2]) + ', ' + string(sz[3]) + ']'
s = s + ', TMP_DIR=''C:\jsoc_cache'', UV= 0, CARRINGTON= 1, CEA= 1'

; 'gx_fov2box, '30-Sep-2018 09:22:00.000', CENTER_ARCSEC=[ 349, 6.78], DX_KM= 366, EUV= 1, NLFFF_ONLY= 1, OUT_DIR='C:\gx_models', SIZE_PIX=[ 897, 481, 449], TMP_DIR='C:\jsoc_cache', UV= 1, CARRINGTON= 1, CEA= 1'

return, s

end
