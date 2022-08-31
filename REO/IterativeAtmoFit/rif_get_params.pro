function rif_get_params, nH, nfreq, npos = npos, nreg = nreg
compile_opt idl2

if n_elements(npos) eq 0 then npos = 1
if n_elements(nreg) eq 0 then nreg = 1

wR = dblarr(npos, nfreq)
wR[*] = 1d 
wL = dblarr(npos, nfreq) 
wL[*] = 1d 
wT = dblarr(nreg, nH) 
wT[*] = 1d 
Tmin = dblarr(1, nreg)
Tmin[*] = 6d3
expMax = 10
expMin = 1d/expMax

param = {wFreq:1d, wTemp:1d, wCross:1d, wR:wR, wL:wL, wT:wT $
       , harms:[2, 3, 4], taus:[1, 100], dunit:1 $
       , mode:3, c:0d, d:0d $
       , Hmin:1d, Tmin:Tmin, Hb:1d, Tb:4d3, barometric:0 $
       , expMax:expMax, expMin:expMin $
       , fluxLim:0, thinLim:5e-1, thinpow:5e-1, uselim:0 $
        }

return, param

end
