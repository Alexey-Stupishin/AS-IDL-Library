pro sample_calc_los_tau

resolve_routine,'asu_get_anchor_module_dir',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('asu_get_anchor_module_dir', /source, /functions)).path, /mark)

; высота, температура, плотность - Selhorst, 2008
filename = dirpath + '..\Sun\selhorst2008_10_708_4_397.sav'
restore, filename
; => height, temperature, density

; поле, угол
filename = dirpath + '..\Samples\LOS_dipole_30_largeFOV2_0.60_1.5.sav'
restore, filename
; => field, inclination

; все массивы одинаковой длины

; частоты (100 частот в диапазоне от 1 до 18 ГГц)
freqs = linspace(1, 18, 100)*1e9
harmonics = [2, 3, 4];

; оптическая толщина (500 значений в диапазоне от 0.01 до 1000 в лог. масштабе)
taus = 10^linspace(-2, 3, 500)

; тормозное по умолчанию учитывается
rc = reo_calculate_los(height, field, inclination, temperature, density, freqs $
                      , harmonics = harmonics, tau_ctrl = taus $
                      , totInts = totInts, totTau = totTau $
                      , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm $
                      )
                      
; для примера: частота около 3 ГГц
freq = 3e9
mf = min(abs(freqs-freq), fidx)
print, 'Frequency = ' + asu_compstr(freqs[fidx])

; для каждой контролируемой величины получим:
; правая поляризация: hR - высоты [Mm], fR - интенсивности [s.f.u/arcsec^2], sR - номера гармоник, tauR - соответствующие контролируемые оптические толлщины  
sample_calc_los_tau_result, fidx, 0, depth, profHeight, profInts, profHarm, taus $
                          , hR, fR, sR, tauR
; левая поляризация - аналогично: hL, fL, sL, tauL
sample_calc_los_tau_result, fidx, 1, depth, profHeight, profInts, profHarm, taus $
                          , hL, fL, sL, tauL
                          
; определим высоты гармоник
b1 = freq/2.799d6
b2 = b1/2
b3 = b1/3
b4 = b1/4
height *= 1d-8

hh = dblarr(5)
hh[2] = interpol(height, field, b2)
hh[3] = interpol(height, field, b3)
hh[4] = interpol(height, field, b4)

; все нарисуем
sample_calc_los_tau_plot, hR, hL, alog10(tauR), alog10(tauL), 'Optical Depth', '$\tau$, -', hh
sample_calc_los_tau_plot, hR, hL, transpose(sR), transpose(sL), 'Harmonics', 'Harmonic number, -', hh
sample_calc_los_tau_plot, hR, hL, transpose(fR), transpose(fL), 'Intensity', 'Intensity, $s.f.u/arcsec^2$', hh

end
