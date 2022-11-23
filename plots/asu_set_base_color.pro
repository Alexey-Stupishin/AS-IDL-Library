pro asu_set_base_color

compile_opt idl2

; k - 0 
cr = bytarr(256)
cg = bytarr(256)
cb = bytarr(256)

; r - 1
cr[1] = 'ff'x
; g - 2
cg[2] = 'ff'x
; b - 3
cb[3] = 'ff'x

; c - 4
cg[4] = 'ff'x
cb[4] = 'ff'x

; m - 5
cr[5] = 'ff'x
cb[5] = 'ff'x

; y - 6
cr[6] = 'ff'x
cg[6] = 'ff'x

; rr - 7
cr[7] = 'ff'x

; ro - 8
cr[8] = 'ff'x
cg[8] = '8c'x

; ry - 9
cr[9] = 'ff'x
cg[9] = 'ff'x

; rg - 10
cg[10] = 'ff'x

; rc - 11
cg[11] = 'ff'x
cb[11] = 'ff'x

; rb - 12
cb[12] = 'ff'x

; rv - 13
cr[13] = 'ba'x
cg[13] = '55'x
cb[13] = 'd3'x

; dw - 252
cr[252] = '40'x
cg[252] = '40'x
cb[252] = '40'x

; hw - 253
cr[253] = '80'x
cg[253] = '80'x
cb[253] = '80'x

; lw - 254
cr[255] = 'c0'x
cg[255] = 'c0'x
cb[255] = 'c0'x

; w - 255
cr[255] = 'ff'x
cg[255] = 'ff'x
cb[255] = 'ff'x

tvlct, cr, cg, cb

end
