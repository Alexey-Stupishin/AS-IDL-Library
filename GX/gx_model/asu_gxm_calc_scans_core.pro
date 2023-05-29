;--------------------------------------------------------------------------;
;     \|/     I will battle for the Sun                           \|/      ;
;    --O--    And I won’t stop until I’m done                    --O--     ;
;     /|\         Placebo, "Battle for the Sun", 2009             /|\      ;  
;--------------------------------------------------------------------------;

pro asu_gxm_calc_scans_core, model, q0, qB, qL, f1, df, n_freq $ ; in
                          , need_freqs = need_freqs, pos_angle = pos_angle, subtr_params = subtr_params $  
                          , renderer = renderer $
                          , maps_ff = maps_ff $
                          , xarc = xarc, visstep = visstep, freq_set = freq_set, Tmax_gs = Tmax_gs, Tmax_ff = Tmax_ff $
                          , dataR_ff = dataR_ff, indexR_ff = indexR_ff, scansR_ff = scansR_ff $
                          , dataL_ff = dataL_ff, indexL_ff = indexL_ff, scansL_ff = scansL_ff $
                          , dataR_gs = dataR_gs, indexR_gs = indexR_gs, scansR_gs = scansR_gs $
                          , dataL_gs = dataL_gs, indexL_gs = indexL_gs, scansL_gs = scansL_gs $
                          , mapfluxR = mapfluxR, mapfluxL = mapfluxL $
                          , modscansR = modscansR, modscansL = modscansL
                          
default, need_freqs, f1 * 10^(dindgen(n_freq) * df)
default, pos_angle, 0
default, subtr_params, []
                              
t0 = systime(/s)

; --- calc free-free, if necessary
n = 0
need_subtr = 0
if n_elements(subtr_params) ne 0 ne 0 then begin 
    n = subtr_params.Count()
    for k = 0, n-1 do begin
        names = tag_names(subtr_params[k])
        idx_exc = where(names eq 'NONE', count)
        if count eq 0 then begin 
            need_subtr = 1
            break
        endif    
    endfor
    if need_subtr then begin
        asu_gxm_calc_scans, model, q0, qB, qL, f1, df, n_freq $
                                   , /ff_only $
                                   , need_freqs = need_freqs, pos_angle = pos_angle $
                                   , renderer = renderer $
                                   , maps = maps_ff, Tmax = Tmax_ff $
                                   , out_dataR = dataR_ff, out_indexR = indexR_ff, scansR = scansR_ff $
                                   , out_dataL = dataL_ff, out_indexL = indexL_ff, scansL = scansL_ff
        message, string((systime(/s)-t0),format="('Synthetic maps computed in ',g0,' seconds')"),/cont
    endif    
endif

;save, filename = 'c:\temp\my.sav', dataR_ff

; --- calc full
asu_gxm_calc_scans, model, q0, qB, qL, f1, df, n_freq $
                           , need_freqs = need_freqs, pos_angle = pos_angle $
                           , renderer = renderer $
                           , maps = maps $
                           , out_dataR = dataR_gs, out_indexR = indexR_gs, scansR = scansR_gs $
                           , out_dataL = dataL_gs, out_indexL = indexL_gs, scansL = scansL_gs $
                           , freq_set = freq_set, visstep = visstep, xarc = xarc, Tmax = Tmax_gs  
message, string((systime(/s)-t0),format="('Synthetic maps computed in ',g0,' seconds')"),/cont

;save, filename = 'c:\temp\mygs.sav', dataR_gs

; --- calc subtr
sz = size(dataR_gs)
if sz[0] eq 2 then sz[3] = 1
mapfluxR = dblarr(sz[1], sz[2], sz[3], n)
mapfluxL = dblarr(sz[1], sz[2], sz[3], n)
modscansR = dblarr(sz[2], sz[3], n)
modscansL = dblarr(sz[2], sz[3], n)
for k = 0, n-1 do begin
    this_subtr = subtr_params[k] 
    dataR_subtr_this = asu_gxm_subtract_data(data_gs = dataR_gs, data_ff = dataR_ff, params = this_subtr)
    asu_gxm_calc_model_data, dataR_gs, indexR_gs $
                           , out_dataR_gs, out_indexR_gs, xarc $
                           , freqs = freq_set, subtr = dataR_subtr_this $ ; no pos_angle, already rotated!
                           , scans = this_modscansR
    mapfluxR[*,*,*,k] = out_dataR_gs
    modscansR[*,*,k] = this_modscansR
    dataL_subtr_this = asu_gxm_subtract_data(data_gs = dataL_gs, data_ff = dataL_ff, params = this_subtr)
    asu_gxm_calc_model_data, dataL_gs, indexL_gs $
                           , out_dataL_gs, out_indexL_gs, xarc $
                           , freqs = freq_set, subtr = dataL_subtr_this $ ; no pos_angle, already rotated!
                           , scans = this_modscansL
    mapfluxL[*,*,*,k] = out_dataL_gs
    modscansL[*,*,k] = this_modscansL
endfor
message, string((systime(/s)-t0),format="('Subtract maps computed in ',g0,' seconds')"),/cont

end
