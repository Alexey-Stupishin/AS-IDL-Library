pro asu_colortable_create, bottom = bottom, center = center, top = top, contrast = contrast, load = load, rb = rb, gb = gb, bb = bb

compile_opt idl2

default, bottom,   [  0,   0,   1]
default, center,   [  1,   1,   1]
default, top,      [  1,   0,   0]
default, contrast, 0.8
default, load,     0

r = dblarr(256)
g = dblarr(256)
b = dblarr(256)

for k = 0, 127 do begin
    r[k] = bottom[0]  + (center[0]-bottom[0])*k/127d
    g[k] = bottom[1]  + (center[1]-bottom[1])*k/127d
    b[k] = bottom[2]  + (center[2]-bottom[2])*k/127d
    r[255-k] = top[0] + (center[0]-top[0])*k/127d
    g[255-k] = top[1] + (center[1]-top[1])*k/127d
    b[255-k] = top[2] + (center[2]-top[2])*k/127d
endfor    
r[0] = 0
g[0] = 0
b[0] = 0

contr_scale = ((indgen(128)/127d)^contrast)*127d
contr_scale_inv = 255 - contr_scale[127:0:-1]

contr_scale = [contr_scale, contr_scale_inv]
r = interpol(r, contr_scale, indgen(256))
g = interpol(g, contr_scale, indgen(256))
b = interpol(b, contr_scale, indgen(256))

rb = byte(r*255)
gb = byte(g*255)
bb = byte(b*255)

if load then tvlct, rb, gb, bb

end
