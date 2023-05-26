pro asu_gxm_calc_scans, model, q0, qB, qL, f1, df, n_freq $
                           , renderer = renderer, ff_only = ff_only $
                           , need_freqs = need_freqs, pos_angle = pos_angle $
                           , maps = maps $
                           , freq_set = freq_set $
                           , out_dataR = out_dataR, out_indexR = out_indexR, scansR = scansR $
                           , out_dataL = out_dataL, out_indexL = out_indexL, scansL = scansL $
                           , visstep = visstep, xarc = xarc, Tmax = Tmax  

if n_elements(maps) eq 0 || ~isa(maps, 'map') then begin
    default, renderer, 'mwgr_transfer_nonlte'
    default, ff_only, 0 
    maps = asu_gxm_gsff_renderer(model, q0, qB, qL, f1, df, n_freq, renderer = renderer, ff_only = ff_only)
endif

default, need_freqs, f1 * 10^(dindgen(n_freq) * df)
default, pos_angle, 0

asu_gxm_IV_to_RL, maps, dataR, indexR, dataL, indexL, freqs = need_freqs, freq_set = freq_set, Tmax = Tmax
asu_gxm_calc_model_data, dataR, indexR $
                       , out_dataR, out_indexR, xarc $
                       , scans = scansR $
                       , freqs = freq_set, pos_angle = pos_angle $
                       , visstep = visstep
asu_gxm_calc_model_data, dataL, indexL $
                       , out_dataL, out_indexL, xarc $
                       , scans = scansL $
                       , freqs = freq_set, pos_angle = pos_angle
                                 
end
