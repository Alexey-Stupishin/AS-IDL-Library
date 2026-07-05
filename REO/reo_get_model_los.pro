pro reo_get_model_los, Hph, Tph, Hc, Tc, dTR, NT, dH, T, D, B, Theta, Nx, Ny

filename = 's:\Projects\IDL\ASlibrary\Samples\mod_dipole_30_largeFOV2.sav'
restore, filename

factor = 1.5

cm_step = box.modstep*960*7.25d7
sz = size(box.bx)
Nx = sz[1]
Ny = sz[2]

box.bx *= factor
box.by *= factor
box.bz *= factor

trans = sqrt(box.bx^2 + box.by^2)
absB = sqrt(trans^2 + box.bz^2)
incl = acos(box.bz/absB)/!DTOR

nTR = ceil((Hc-Hph)/dTR)
HTR = linspace(Hph, Hc, nTR)
TTR = 10^interpol(alog10([Tph, Tc]), [Hph, Hc], HTR)

HF = dindgen(sz[3])*cm_step
idx = where(HF gt Hc)

H0 = [HTR, HF[idx]]
dH0 = H0[1:-1]-H0[0:-2]
dH0 = [dH0[0], dH0]
T0 = [TTR, dblarr(n_elements(idx))+Tc]

dH = dblarr(sz[1]*sz[2], n_elements(H0))
T = dblarr(sz[1]*sz[2], n_elements(H0))
B = dblarr(sz[1]*sz[2], n_elements(H0))
Theta = dblarr(sz[1]*sz[2], n_elements(H0))

for x = 0, sz[1]-1 do begin
    for y = 0, sz[2]-1 do begin
        pos = x*sz[1] + y
        
        absB0 = interpol([absB[x,y,0], absB[x,y,idx[0]]], [HF[0], HF[idx[0]]], HTR)
        incl0 = interpol([incl[x,y,0], incl[x,y,idx[0]]], [HF[0], HF[idx[0]]], HTR)
        
        B[pos, *] = [absB0, transpose(absB[x, y, idx], [2, 0, 1])]
        Theta[pos, *] = [incl0, transpose(incl[x, y, idx], [2, 0, 1])]
        
        dH[pos, *] = dH0
        T[pos, *] = T0
    endfor
endfor

D = NT/T

end
