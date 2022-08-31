function rif_calc_1_iteration, ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, H, T, D, pos, params $
                             , R, calcR, L, calcL, cntR = cntR, cntL = cntL $ 
                             , use_mask = use_mask, freqs = freqs, idxR = idxR, idxL = idxL, _extra = _extra
compile_opt idl2

freqs = rif_get_freq_idxs(freqsR, freqsL, idxR, idxL)

R = dblarr(n_elements(Ht1), n_elements(freqs))
L = dblarr(n_elements(Ht1), n_elements(freqs))
cntR = intarr(n_elements(Ht1), n_elements(freqs))
cntL = intarr(n_elements(Ht1), n_elements(freqs))

calcR = dblarr(n_elements(freqs))
calcL = dblarr(n_elements(freqs))

for f = 0, n_elements(freqs)-1 do begin
    rc = reo_calculate_map( $
      ptr, H, T, D, freqs[f] $
    , harmonics = params.harms, tau_ctrl = params.taus $
    , fluxR = fluxR $
    , fluxL = fluxL $
    , depthR = depthR, heightsR = heightsR $
    , depthL = depthL, heightsL = heightsL $
    )
    
    useR = (where(f eq idxR, /NULL) ne !NULL)
    useL = (where(f eq idxL, /NULL) ne !NULL)
    
    if useR then begin
        rcr = reo_convolve_map(ptr, fluxR, freqs[f], scanR)
        calcR[f] = scanR[pos]
        rcr = reo_beam_multiply_map(ptr, fluxR, multR, freqs[f], pos)
    endif    
    if useL then begin
        rcr = reo_convolve_map(ptr, fluxL, freqs[f], scanL)
        calcL[f] = scanL[pos]
        rcr = reo_beam_multiply_map(ptr, fluxL, multL, freqs[f], pos)
    endif    

    sz = size(fluxR)
    for i = 0, sz[1]-1 do begin
        for j = 0, sz[2]-1 do begin
            for m = 0, n_elements(Ht1)-1 do begin
                if useR && depthR[i,j] ge params.dunit && Ht1[m] le heightsR[i,j,params.dunit] && heightsR[i,j,params.dunit] lt Ht2[m] && multR[i,j] gt 0 then begin
                    R[m,f] += multR[i,j]
                    cntR[m,f] += 1
                end
                if useL && depthL[i,j] ge params.dunit && Ht1[m] lt heightsL[i,j,params.dunit] && heightsL[i,j,params.dunit] lt Ht2[m] && multL[i,j] gt 0 then begin
                    L[m,f] += multL[i,j]
                    cntL[m,f] += 1
                end
            endfor
        endfor
    endfor
        
endfor

R = R[*, idxR]
cntR = cntR[*, idxR]
calcR = calcR[idxR]

L = L[*, idxL]
cntL = cntL[*, idxL]
calcL = calcL[idxL]

return, 0

end
