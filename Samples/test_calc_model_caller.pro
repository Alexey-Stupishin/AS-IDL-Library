pro test_calc_model_caller

H =    [1,   1e8, 1.1e8, 1.2e8, 2e10] ; cm - высота над фотосферой
Temp = [1e4, 1e4,   1e6,   2e6,  2e6] ; K - температуры на соответствующих высотах
Dens = 3e15/Temp ; cm^{-3} - плотности электронов там же

Bph = 3000 ; поле на фотосфере в центре
harmonics = [2, 3, 4] ; номера учитываемых гармоник
freefree = 1 ;1 - учет freefree, 0 - игнорировать
freqs = asu_linspace(4, 18, 50)*1e9 ; частоты

;----------------------------------------------------------------------
tt = systime(/seconds)
result = test_calc_model(H, Temp, Dens, Bph, freqs, harmonics, freefree)
print, 'Performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)
;----------------------------------------------------------------------

; полный поток источника
pR = plot(result.freqs, result.FLUXR)
pL = plot(result.freqs, result.FLUXL, overplot = pR)

; поток в максимуме скана
pR = plot(result.freqs, result.MAXR)
pL = plot(result.freqs, result.MAXL, overplot = pR)

end
