pro test_calc_model_caller_comp

H =    [1,   1e8, 1.1e8, 1.2e8, 2e10] ; cm - высота над фотосферой
Temp = [1e4, 1e4,   1e6,   2e6,  2e6] ; K - температуры на соответствующих высотах
Dens = 3e15/Temp ; cm^{-3} - плотности электронов там же

Bph = 3000 ; поле на фотосфере в центре
harmonics = [2, 3, 4] ; номера учитываемых гармоник
freefree = 1 ;1 - учет freefree, 0 - игнорировать
freqs = asu_linspace(4, 18, 10)*1e9 ; частоты

;----------------------------------------------------------------------
tt = systime(/seconds)
result = test_calc_model(H, Temp, Dens, Bph, freqs, harmonics, freefree)
print, 'Performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)
;----------------------------------------------------------------------

; полный поток источника
pR = plot(result.freqs, result.FLUXR, '-r2')
pL = plot(result.freqs, result.FLUXL, '-b2', overplot = pR)

; поток в максимуме скана
mR = plot(result.freqs, result.MAXR, '-r2')
mL = plot(result.freqs, result.MAXL, '-b2', overplot = mR)

;----------------------------------------------------------------------
tt = systime(/seconds)
result = test_calc_model(H, Temp, Dens, Bph, freqs, harmonics, 0)
print, 'Performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)
;----------------------------------------------------------------------

; полный поток источника
pR2 = plot(result.freqs, result.FLUXR, '--r2', overplot = pR)
pL2 = plot(result.freqs, result.FLUXL, '--b2', overplot = pR)

; поток в максимуме скана
mR2 = plot(result.freqs, result.MAXR, '--r2', overplot = mR)
mL2 = plot(result.freqs, result.MAXL, '--b2', overplot = mR)

end
