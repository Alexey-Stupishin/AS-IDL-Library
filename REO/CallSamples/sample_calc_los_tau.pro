pro sample_calc_los_tau

; высота, температура, плотность
; атмосфера - Selhorst, 2008
resolve_routine,'asu_get_anchor_module_dir',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('asu_get_anchor_module_dir', /source, /functions)).path, /mark)
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

; оптическая толщина (208 значений в диапазоне от 0.01 до 10 в лог. масштабе)
taus = 10^linspace(-2, 1, 208)

rc = reo_calculate_los(height, field, inclination, temperature, density, freqs $
                      , harmonics = harmonics, tau_ctrl = taus $
                      , totInts = totInts, totTau = totTau $
                      , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm $
                      , freefree = 1 $
                      )
                      
; для примера: частота 3 ГГц
freq = 3e9
mf = min(abs(freqs-freq), fidx)
print, 'Frequency = ' + asu_compstr(freqs[fidx])

; для каждой контролируемой величины (в правой поляризации) получим:
hR = profHeight[0, 0:depth[0, fidx]-1, fidx] ; высоты
fR = profInts[0, 0:depth[0, fidx]-1, fidx] ; интенсивности
sR = profHarm[0, 0:depth[0, fidx]-1, fidx] ; номера гармоник
tR = taus[0:depth[0, fidx]-1] ; на соответствующих контролируемых оптических толлщинах 

; и то же самое в левой:
hL = profHeight[1, 0:depth[1, fidx]-1, fidx] ; высоты
fL = profInts[1, 0:depth[1, fidx]-1, fidx] ; интенсивности
sL = profHarm[1, 0:depth[1, fidx]-1, fidx] ; номера гармоник
tL = taus[0:depth[1, fidx]-1] ; на соответствующих контролируемых оптических толлщинах 

pR = plot(hR, alog10(tR), '-r3')
pL = plot(hL, alog10(tL), '-b2', overplot = pR)

pR = plot(hR, sR, '-r3')
pL = plot(hL, sL, '-b2', overplot = pR)

pR = plot(hR, fR, '-r3')
pL = plot(hL, fL, '-b2', overplot = pR)

end
