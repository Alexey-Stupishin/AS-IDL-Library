pro sample_calc_los_tau_v2

resolve_routine,'asu_get_anchor_module_dir',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('asu_get_anchor_module_dir', /source, /functions)).path, /mark)

; высота, температура, плотность - Selhorst, 2008
filename = dirpath + '..\Sun\selhorst2008_10_708_4_397.sav'
restore, filename
; => height, temperature, density
; массивы одинаковой длины

; поле, угол
; загрузим поле диполя
filename = dirpath + '..\Samples\mod_dipole_30_largeFOV2.sav'
restore, filename

; поле 140х140 пикселей, макс. поле в центре на фотосфере 2000 Гс
; возмем точку несколько в стороне от оси диполя (69, 82.8), макс. поле 3000 Гс (factor = 1.5)
t = asu_box_get_los(box, [69, 83], factor = 1.5)
; => t.height, t.field, t.inclination
; массивы одинаковой длины

; частоты (1000 частот в диапазоне от 1 до 18 ГГц)
freqs = linspace(1, 18, 1000)*1e9
harmonics = [2, 3, 4];

; оптическая толщина (5000 значений в диапазоне от 0.01 до 1000 в лог. масштабе)
taus = 10^linspace(-2, 3, 5000)

; тормозное по умолчанию учитывается
rc = reo_calculate_los(t.height, t.field, t.inclination, height, temperature, density, freqs $
                      , harmonics = harmonics, tau_ctrl = taus $
                      , totInts = totInts, totTau = totTau $
                      , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm, profAbsorb = profAbsorb $
                      )
                      
; для примера: частота около 7.3 ГГц
freq = 7.3e9
mf = min(abs(freqs-freq), fidx)
print, 'Frequency = ' + asu_compstr(freqs[fidx])

; для каждой контролируемой величины получим:
; правая поляризация: hR - высоты [Mm], fR - интенсивности [s.f.u/arcsec^2], sR - номера гармоник
;                   , aR - коэффициенты поглощения [cm^-1]   
;                   , tauR - соответствующие контролируемые оптические толщины  
sample_calc_los_tau_result, fidx, 0, depth, profHeight, profInts, profHarm, profAbsorb, taus $
                          , hR, fR, sR, aR, tauR
; левая поляризация - аналогично: hL, fL, sL, aR, tauL
sample_calc_los_tau_result, fidx, 1, depth, profHeight, profInts, profHarm, profAbsorb, taus $
                          , hL, fL, sL, aL, tauL
         
; определим высоты гармоник
b1 = freq/2.799d6
b2 = b1/2
b3 = b1/3
b4 = b1/4
t.height *= 1d-8

hh = dblarr(5)
hh[2] = interpol(t.height, t.field, b2)
hh[3] = interpol(t.height, t.field, b3)
hh[4] = interpol(t.height, t.field, b4)

; все нарисуем
sample_calc_los_tau_plot, hR, hL, alog10(tauR), alog10(tauL), 'Optical Depth', '$log(\tau, -)$', 0, hh, /zero
sample_calc_los_tau_plot, hR, hL, transpose(sR), transpose(sL), 'Harmonics', 'Harmonic number, -', 1, hh
sample_calc_los_tau_plot, hR, hL, transpose(fR), transpose(fL), 'Intensity', 'Intensity, $s.f.u/arcsec^2$', 0, hh
sample_calc_los_tau_plot, hR, hL, transpose(alog10(aR)), transpose(alog10(aL)), 'Absorbtion', 'log(Absorbtion, $cm^{-1})$', 1, hh

; гармоники на температурном профиле
tlog = alog10(temperature)
mmt = minmax(tlog)
dmmt = mmt[1]-mmt[0]
dlog = alog10(density)
mmd = minmax(dlog)
dmmd = mmd[1]-mmd[0]
temp = plot(height*1d-8, tlog, color = 'RED', linestyle = '-', thick = 2, xrange = [0, max([hR, hL])] $
          , title = 'Atmoshpere', xtitle = 'Height, Mm', ytitle = 'log(T, K)')
dens = plot(height*1d-8, (dlog-mmd[0])/dmmd*dmmt+mmt[0], color = 'BLACK', linestyle = '-', thick = 2, overplot = temp)
p = plot([hh[2], hh[2]], mmt, color = 'ORANGE', linestyle = ':', thick = 2, overplot = temp)
p = plot([hh[3], hh[3]], mmt, color = 'LIME GREEN', linestyle = ':', thick = 2, overplot = temp)
p = plot([hh[4], hh[4]], mmt, color = 'DEEP SKY BLUE', linestyle = ':', thick = 2, overplot = temp)

end
