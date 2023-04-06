function asu_gxbox_get_aia, box, wave, aia_data, aia_index

rc = 0

aia_data = !NULL
aia_index = !NULL

query = 'AIA_' + asu_compstr(wave)

refmaps=*(box.Refmaps())
for i=0, refmaps->get(/count)-1 do begin
    print, refmaps->get(i,/id)
    if refmaps->get(i,/id) eq query then begin
        aiastr = refmaps->get(i,/map)
        aia_data = double(aiastr.data)
        sz = size(aia_data)
        aia_index = {XCEN:aiastr.xc, YCEN:aiastr.yc, CDELT1:aiastr.dx, CDELT2:aiastr.dy, RSUN_OBS:aiastr.rsun $
                   , CRPIX1:(sz[1]+1)*0.5d, CRVAL1:aiastr.xc, CRPIX2:(sz[2]+1)*0.5d, CRVAL2:aiastr.yc}
        rc = 1
        break
    endif
endfor

return, rc

end
