function rtu_map_convolve, map, dH, dV, step, mode = mode, c = c, b = b

szmap = size(map)
ndH = n_elements(dH)
;assert, szmap[1] = ndH
;assert, szmap[2] = n_elements(dV)

purescan = map # dV

scan = convol(purescan, dH, /EDGE_TRUNCATE) / step[0]

return, scan

end
