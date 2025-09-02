pro sample_calc_los_tau_result, fidx, mode, depth, profHeight, profInts, profHarm, taus, h, f, s, tau   

h = profHeight[mode, 0:depth[mode, fidx]-1, fidx] * 1d-8 ; высоты, в Мм
f = profInts[mode, 0:depth[mode, fidx]-1, fidx] ; интенсивности
s = profHarm[mode, 0:depth[mode, fidx]-1, fidx] ; номера гармоник
tau = taus[0:depth[mode, fidx]-1] ; на соответствующих контролируемых оптических толлщинах

end
