pro test_calc_model_caller_comp

H =    [1,   1e8, 1.1e8, 1.2e8, 2e10] ; cm - высота над фотосферой
Temp = [1e4, 1e4,   1e6,   2e6,  2e6] ; K - температуры на соответствующих высотах
Dens = 3e15/Temp ; cm^{-3} - плотности электронов там же

depth = 18e8 ; глубина погружения, см
Bph = 3000 ; поле на фотосфере в центре, Гс
visstep = 1 ; шаг радиокарты, угл.сек (чем мельче, тем точнее, но дольше считать)
harmonics = [2, 3, 4] ; номера учитываемых гармоник
freqs = asu_linspace(3, 18, 10)*1e9 ; частоты

box = asu_get_dipole_model(depth, Bph)

;----------------------------------------------------------------------
tt = systime(/seconds)
result = reo_calc_scans_by_box(box, visstep, H, Temp, Dens, freqs, harmonics, 1, /model)
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
result = reo_calc_scans_by_box(box, visstep, H, Temp, Dens, freqs, harmonics, 0, /model)
print, 'Performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)
;----------------------------------------------------------------------

; полный поток источника
pR2 = plot(result.freqs, result.FLUXR, '--r2', overplot = pR)
pL2 = plot(result.freqs, result.FLUXL, '--b2', overplot = pR)

; поток в максимуме скана
mR2 = plot(result.freqs, result.MAXR, '--r2', overplot = mR)
mL2 = plot(result.freqs, result.MAXL, '--b2', overplot = mR)

end
