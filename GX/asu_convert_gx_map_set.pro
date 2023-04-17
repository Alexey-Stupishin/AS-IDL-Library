pro asu_convert_gx_map_set, map, data, index, freqs = freqs

data = !NULL
index = !NULL

mapex = map.getlist()
nlist = mapex.Count()

for k = 0, nlist-1 do begin
    rmap = mapex[k]
    if data eq !NULL then begin
        sz = size(rmap.data)
        asu_convert_gx_map_get_index, rmap, index1
        data = dblarr(sz[1], sz[2], nlist)
        index = replicate(index1, nlist)
    endif
    asu_convert_gx_map, rmap, data1, index1
    data[*,*,k] = data1
    index[k] = index1    
endfor

n = n_elements(freqs)
if n ne 0 then begin
    m_freqs = index.freq
    sz = size(data)
    keep = intarr(n)
    for k = 0, n-1 do begin
        mm = min(abs(freqs[k]-m_freqs), idx)
        keep[k] = idx
    endfor
    data = data[*,*,keep]
    index = index[keep]
endif

end
