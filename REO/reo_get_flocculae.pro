pro reo_get_flocculae, ptr, freqsR, freqsL, model_mask, masks_n, pos, params, RB, LB
compile_opt idl2

freqs = rif_get_freq_idxs(freqsR, freqsL, idxR, idxL)

RB = dblarr(n_elements(freqs), n_elements(pos))
LB = dblarr(n_elements(freqs), n_elements(pos))

sz = size(model_mask)
for k = 0, n_elements(freqs)-1 do begin
    fluxRW = dblarr(sz[1], sz[2])
    fluxLW = dblarr(sz[1], sz[2])
    for n = 0, n_elements(masks_n)-1 do begin
        length = asu_get_fontenla2009(masks_n[n], Hf, Tf, Df)
        
        rc = reo_calculate_map( $
          ptr, Hf, Tf, Df, freqs[k] $
        , freefree = 1, no_gst = 1 $  
        , harmonics = params.harms, tau_ctrl = params.taus $
        , fluxR = fluxR $
        , fluxL = fluxL $
        )
        
        selmask = where(model_mask eq masks_n[n], /NULL)
        if selmask ne !NULL then begin
            fluxRW[selmask] += fluxR[selmask]
            fluxLW[selmask] += fluxL[selmask]
        endif
    end
    rcr = reo_convolve_map(ptr, fluxRW, freqs[k], scanR)
    rcl = reo_convolve_map(ptr, fluxLW, freqs[k], scanL)
    for p = 0, n_elements(pos)-1 do begin
        RB[k, p] = scanR[pos[p]]
        LB[k, p] = scanL[pos[p]]
    endfor
endfor    

RB = RB[idxR, *]
LB = RB[idxL, *]

end
