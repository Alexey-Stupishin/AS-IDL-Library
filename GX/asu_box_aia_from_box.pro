pro asu_box_aia_from_box, box, aia

naia = 0;
rmaps = (*box.refmaps)[0]
nmaps = rmaps.get(/COUNT)
szx = 0
szy = 0
for k = 0, nmaps-1 do begin
    m = rmaps.getmap(k)
    if strcmp(m.ID, 'aia', 3, /FOLD_CASE) then begin
        sz = size(m.data)
        szx = max([szx, sz(1)])
        szy = max([szy, sz(2)])
        naia = naia + 1;
    endif
endfor           

if naia gt 0 then begin
    aia = {ids:strarr(naia), data:dblarr(szy, szx, naia), size:lonarr(2, naia) $
         , center:dblarr(2, naia), step:dblarr(2, naia), RSun:dblarr(naia)}
    naia = 0;
    for k = 0, nmaps-1 do begin
        m = rmaps.getmap(k)
        if strcmp(m.ID, 'aia', 3, /FOLD_CASE) then begin
            aia.ids[naia] = m.ID
            sz = size(m.data)
            aia.size[0, naia] = sz[2] 
            aia.size[1, naia] = sz[1] 
            aia.center[*, naia] = [m.YC, m.XC] 
            aia.step[*, naia] = [m.DY, m.DX] 
            aia.RSun[naia] = m.RSUN 
            aia.data[0:sz[2]-1, 0:sz[1]-1, naia] = double(transpose(m.data, [1, 0])) 
            naia = naia + 1;
        endif
    endfor           
endif else begin
    aia = {ids:"", data:0, size:0, center:0, step:0, RSun:0}
endelse

end