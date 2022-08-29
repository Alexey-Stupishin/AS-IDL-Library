function reo_iter_get_params, nH, nfreq, npos = npos, nreg = nreg

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
expMax = 3
expMin = 1d/expMax

param = {wFreq:1d, wTemp:1d, wCross:1d, wR:wR, wL:wL, wT:wT $
       , harms:[2, 3, 4], taus:[1, 100], dunit:1 $
       , mode:3, c:0d, d:0d, scanlims:!NULL $
       , Hmin:1d, Tmin:Tmin, Hb:1d, Tb:4d3, barometric:0 $
       , expMax:expMax, expMin:expMin $
       , fluxLim:5d-2, thinLim:5e-1, thinpow:5e-1, uselim:0, solve_mode:'-NM' $ 
       , resabslim:1d-2, reslim:3d-2, rescntstab:20, rescntmax:50 $
       , Hshow:0d $
        }

return, param

end
