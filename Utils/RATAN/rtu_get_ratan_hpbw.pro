; freqs in GHz!

pro rtu_get_ratan_hpbw, freqs, vert, horz, mode = mode, c = c, b = b

vert = 7.5d * 60d * 30d / freqs
horz = 0.2d + 9.4d * 30d / freqs

end
