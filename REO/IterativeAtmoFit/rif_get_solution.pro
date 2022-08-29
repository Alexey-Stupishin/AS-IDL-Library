function rif_get_solution, freqs, idxR, idxL, R, L, obsR, obsL, calcR, calcL, T, params $
                         , resT, M, F, w, incl  
compile_opt idl2

M = [[R], [L]]
obsF = [obsR, obsL];
calcF = [calcR, calcL];
w = params.wFreq*[params.wR, params.wL];

sz = size(M)
nH = sz[1]

incl = intarr(n_elements(freqs)) + 1
totalM = total(M, 1)
thin = calcF - totalM
F = obsF - thin
for i = 0, n_elements(freqs)-1 do begin
    if obsF[i] le param.fluxLim * max(obsF) then begin
        incl[i] = 0
    endif else if totalM[i] eq 0 then begin 
        incl[i] = 0
    endif else begin
        v = thin[i]/calcF[i] 
        if v gt params.thinLim then begin
            incl[i] = 0
        endif else begin
            w[i] *= (1d - v/params.thinLim)^params.thinPow
        endelse
    endelse
    
    if incl[i] then begin
        for h = 0, nH-1 do begin
            if M[h, i] lt param.useLim*calcF[i] then begin
                F[i] -= M[h, i]
                M[h, i] = 0
            endif
        endfor
        F[i] = max([F[i], 0])
    end
endfor

incid = where(incl, /NULL)
M = M[*, incid]
F = F[incid]
w = w[incid]

sz = size(M)

if param.wTemp > 0 then begin
    sm = total(M)/n_elements(where(M gt 0))*1e-6
    Z = dblarr(n_elements(T), n_elements(T)-1)
    for i = 0, n_elements(T)-2 do begin
        Z[i:i+1, i] = [Tc(i), -Tc(i+1)]*sm;
    endfor
    M = [[M], [Z]]
    F = [F, dblarr(n_elements(T)-1)]
    w = [w, dblarr(n_elements(T)-1) + param.wTemp];
endif

;x = lscov(M, Fr', w');
;x = min(param.expMax, max(x, param.expMin));
;resT = x';

return, 0

end
 