function rif_calc_1_iteration, ptr, mask_set, model_mask, freqs, robs, lobs, params

rc = reo_set_atmosphere_mask_set(ptr, mask_set, model_mask)


rc = reo_calculate_map_atm(ptr, freq, FluxR = FluxR , FluxL = FluxL $
                         , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = sR $
                         , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = sL $
                          )

return, 0

end
