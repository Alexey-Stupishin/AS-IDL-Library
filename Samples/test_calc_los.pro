pro test_calc_los

; высота, поле, угол, температура, плотность
H  = [   0,    1,  1.2,  1.5,    2,    3,    4,    5,  10,  15]*1e8
B  = [2500, 2000, 1950, 1900, 1800, 1600, 1400, 1200, 700, 450]
Th = [  40,   35,   30,   25,   20,   25,   30,   35,  40,  45]
T  = [0.01, 0.01,    1,    2,    2,    2,    2,    2,   2,   2]*1e6
D  = 3e15/T

; частоты (100 частот в диапазоне от 4 до 18 ГГц)
freqs = asu_linspace(4, 18, 100)*1e9

; оптическая толщина (208 значений в диапазоне от 0.01 до 10 в лог. масштабе)
taus = 10^asu_linspace(-2, 1, 208)

rc = reo_calculate_los(H, B, Th, T, D, freqs $
                      , harmonics = [2, 3, 4], tau_ctrl = taus $
                      , totInts = totInts, totTau = totTau $
                      , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm $
                      , freefree = 1 $
                      )
freq = 10e9
mf = min(abs(freqs-freq), fidx)
print, 'Frequency = ' + asu_compstr(freqs[fidx])

; для каждой контролируемой величины (в правой поляризации) получим:
hR = profHeight[0, 0:depth[0, fidx]-1, fidx] ; высоты
fR = profInts[0, 0:depth[0, fidx]-1, fidx] ; интенсивности
sR = profHarm[0, 0:depth[0, fidx]-1, fidx] ; номера гармоник
tR = taus[0:depth[0]-1] ; на соответствующих контролируемых оптических толлщинах 

; и то же самое в левой:
hL = profHeight[1, 0:depth[1, fidx]-1, fidx] ; высоты
fL = profInts[1, 0:depth[1, fidx]-1, fidx] ; интенсивности
sL = profHarm[1, 0:depth[1, fidx]-1, fidx] ; номера гармоник
tL = taus[0:depth[0]-1] ; на соответствующих контролируемых оптических толлщинах 

pR = plot(hR, alog10(tR), '-r3')
pL = plot(hL, alog10(tL), '-b2', overplot = pR)

pR = plot(hR, sR, '-r3')
pL = plot(hL, sL, '-b2', overplot = pR)

pR = plot(hR, fR, '-r3')
pL = plot(hL, fL, '-b2', overplot = pR)

end
