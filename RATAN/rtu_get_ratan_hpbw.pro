pro rtu_get_ratan_hpbw, freqs, vert, horz, mode = mode, c = c, b = b
; freqs in GHz!

vert = 7.5d * 60d * 30d / freqs

default, mode, 4
default, c, 0
default, b, 8.5
lamb = 30d/freqs

case mode of
   1: horz =          8.5  *lamb
   2: horz =  4.38  + 6.87 *lamb
   3: horz =  0.009 + 8.338*lamb
   4: horz =      c +     b*lamb
   5: horz =  0.2   + 9.4  *lamb
   6: horz = -0.16  + 8.162*lamb
   else: horz =  c  + b*lamb
endcase

end
