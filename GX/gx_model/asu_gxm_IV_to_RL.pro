pro asu_gxm_IV_to_RL, mapIV_T, dataR, indexR, dataL, indexL, freqs = freqs, freq_set = freq_set, Tmax = Tmax

rmap = mapIV_T
if isa(rmap, 'string') then begin
    restore, rmap
    rmap = map
endif
if isa(rmap, 'map') then begin
    rmap = rmap.getlist()
endif

dataI = !NULL
dataV = !NULL
indexI = !NULL
indexV = !NULL
nlist = rmap.Count()
nm = nlist/2;
sz = size(rmap[0].data)
for k = 0, nlist-1 do begin
    map_k = rmap[k]
    asu_gxm_map2data, map_k, data1, index1
    stokes = index1.stokes
    if stokes eq 'I' then begin
        if indexI eq !NULL then begin
            indexI = replicate(index1, nlist)
            dataI = dblarr(index1.naxis1, index1.naxis2, nm)
            cntI = 0
        endif
        indexI[cntI] = index1
        dataI[*,*,cntI] = data1
        cntI++
    end    
    if stokes eq 'V' then begin
        if indexV eq !NULL then begin
            indexV = replicate(index1, nlist)
            dataV = dblarr(index1.naxis1, index1.naxis2, nm)
            cntV = 0
        endif
        indexV[cntV] = index1
        dataV[*,*,cntV] = data1
        cntV++
    end    
endfor

asu_gxm_freq_filter, indexI, dataI, freqs = freqs, freq_set = freq_set
asu_gxm_freq_filter, indexV, dataV, freqs = freqs

Tmax = max(dataI)

sz = size(dataI)
if n_elements(dataI) ne n_elements(dataV) then message, 'wrong IV map'

mult = 3.61d-11*(freqs*1e-9)^2*indexI[0].dx*indexI[0].dy

dataR = dataI 
dataL = dataI
for k = 0, n_elements(freqs)-1 do begin 
    dataR[*,*,k] = (dataI[*,*,k] + dataV[*,*,k])*0.5d*mult[k]
    dataL[*,*,k] = (dataI[*,*,k] - dataV[*,*,k])*0.5d*mult[k]
endfor

indexR = indexI
indexL = indexI

indexR.DATAUNIT = 'sfu'
indexL.DATAUNIT = 'sfu'
indexR.DATATYPE = 'Flux'
indexL.DATATYPE = 'Flux'
indexR.STOKES = 'RCP'
indexL.STOKES = 'LCP'

end
