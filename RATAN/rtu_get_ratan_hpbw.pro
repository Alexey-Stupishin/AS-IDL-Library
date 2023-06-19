pro rtu_get_ratan_hpbw, freqs, vert, horz, mode = mode, c = c, b = b
; freqs in GHz!

vert = 7.5d * 60d * 30d / freqs

default, mode, 3
default, c, 0.009
default, b, 8.338
lamb = 30d/freqs

case mode of
   1: horz =          8.5  *lamb ; simple, from SAO site
   2: horz =  4.38  + 6.87 *lamb ; theoretical for spiral feed, unrealistic
   3: horz =  0.009 + 8.338*lamb ; some last private letter (S. Tokchukova? Need to clarify)
;   4: horz =  user defined by table lookup, TODO
   5: horz =  0.2   + 9.4  *lamb ; wide, source unknown
   6: horz = -0.16  + 8.162*lamb ; 1-3 GHz, 2023 (spring) by N.Ovchinnikova/M.Lebedev
   else: horz =  c  +     b*lamb ; default, see mode = 3
endcase

end
