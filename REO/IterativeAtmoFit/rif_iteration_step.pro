function rif_iteration_step, ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, H, calcT, NT, pos, params, calcR, calcL $
                           , calcD = calcD, use_mask = use_mask, freqs = freqs, idxR = idxR, idxL = idxL, _extra = _extra
compile_opt idl2

Hin = [params.Hb, H]
Tin = [params.Tb, calcT]
Din = NT/Tin

idx = where(Tin lt params.Tmin, /NULL)
if idx ne !NULL then Tin[idx] = params.Tmin
idx = where(Hin lt params.Hmin, /NULL)
if idx ne !NULL then Tin[idx] = params.Tmin

rc = rif_calc_1_iteration(ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, Hin, Tin, Din, pos, params $
                        , R, calcR, L, calcL, freqs = freqs, idxR = idxR, idxL = idxL, _extra = _extra)

solution = rif_get_solution(freqs, idxR, idxL, R, L, obsR, obsL, calcR, calcL, calcT, params)

nextT = Tin * solution
calcD = Din[1:-1] 

return, nextT

end
