pro rtu_create_ratan_diagrams, freq, sz, step, basearc, diagrH, diagrV, mode = mode, c = c, b = b

lng = sz[0]
points = basearc[1]/step[1] + indgen(sz[1])
rtu_get_ratan_hpbw, freq, vert, horz, mode = mode, c = c, b = b
diagrH = rtu_get_gauss_norm(horz/step[0]/2d, (lng+1)/2d, lng)
diagrV = rtu_get_gauss_points(vert/step[1]/2d, points)

end
