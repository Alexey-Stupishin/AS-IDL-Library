function asu_gci, color

coltab = hash()
coltab['k'] = 0
coltab['r'] = 1
coltab['g'] = 2
coltab['b'] = 3
coltab['c'] = 4
coltab['m'] = 5
coltab['y'] = 6
coltab['rr'] = 7
coltab['ro'] = 8
coltab['ry'] = 9
coltab['rg'] = 10
coltab['rc'] = 11
coltab['rb'] = 12
coltab['rv'] = 13
coltab['dw'] = 252
coltab['hw'] = 253
coltab['lw'] = 254
coltab['w'] = 255

return, coltab.hasKey(color) ? coltab[color] : 0

end
