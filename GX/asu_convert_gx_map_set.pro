pro asu_convert_gx_map_set, map, data, index, freqs = freqs, freq_set = freq_set

data = !NULL
index = !NULL

rmap = map
if isa(rmap, 'string') then begin
    restore, rmap
    rmap = map
endif
if isa(rmap, 'map') then begin
    rmap = rmap.getlist()
endif

nlist = rmap.Count()

for k = 0, nlist-1 do begin
    map_k = rmap[k]
    if data eq !NULL then begin
        sz = size(map_k.data)
        asu_convert_gx_map_get_index, map_k, index1
        data = dblarr(sz[1], sz[2], nlist)
        index = replicate(index1, nlist)
    endif
    asu_convert_gx_map, map_k, data1, index1
    data[*,*,k] = data1
    index[k] = index1    
endfor

freq_set = index.freq
n = n_elements(freqs)
if n ne 0 then begin
    sz = size(data)
    keep = intarr(n)
    for k = 0, n-1 do begin
        mm = min(abs(freqs[k]-freq_set), idx)
        keep[k] = idx
    endfor
    data = data[*,*,keep]
    index = index[keep]
    freq_set = freq_set[keep]
endif

end
