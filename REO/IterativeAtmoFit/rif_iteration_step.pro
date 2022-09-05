function rif_iteration_step, ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, H, calcT, NT, pos, params, calcR, calcL $
                           , calcD = calcD, freqs = freqs, idxR = idxR, idxL = idxL, _extra = _extra
compile_opt idl2

Hin = [params.Hb, H]
Tin = [params.Tb, calcT]

idx = where(Tin lt params.Tmin, /NULL)
if idx ne !NULL then Tin[idx] = params.Tmin
idx = where(Hin le params.Hmin, /NULL)
if idx ne !NULL then Tin[idx] = params.Tmin

if params.barometric then begin
    Din = asu_atm_barometric(Hin, Tin, NT)
endif else begin    
    Din = NT/Tin
endelse    

rc = rif_calc_1_iteration(ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, Hin, Tin, Din, pos, params $
                        , R, calcR, L, calcL, freqs = freqs, idxR = idxR, idxL = idxL, _extra = _extra)

solution = rif_get_solution(freqsR, idxR, freqsL, idxL, R, L, obsR, obsL, calcR, calcL, Tin[1:-1], params)

nextT = Tin[1:-1] * solution
calcD = Din[1:-1] 

return, nextT

end
