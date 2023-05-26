function asu_gxm_nm_calc, x, context $
        , dataR_ff = dataR_ff, dataL_ff = dataL_ff $
        , dataR_gs = dataR_gs, dataL_gs = dataL_gs $
        , mapfluxR = mapfluxR, mapfluxL = mapfluxL $
        , modscansR = modscansR, modscansL = modscansL

asu_gxm_calc_scans_core, context.model, 10^x[0], x[1], x[2], context.f1, context.df, context.n_freq $
        , maps_ff = context.maps_ff $
        , need_freqs = context.freqs, pos_angle = context.pos_angle, subtr_params = context.subtr_params $ ; in
        , xarc = xarc, visstep = visstep, freq_set = freq_set, Tmax_gs = Tmax, Tmax_ff = Tmax_ff $
        , modscansR = modscansR, modscansL = modscansL $
        , dataR_ff = dataR_ff, dataL_ff = dataL_ff $
        , dataR_gs = dataR_gs, dataL_gs = dataL_gs $
        , mapfluxR = mapfluxR, mapfluxL = mapfluxL

if context.resample.Count() eq 0 then asu_gxm_nm_resample, context, xarc  

r = asu_gxm_nm_residual(context, modscansR, modscansL)

return, r 

end
