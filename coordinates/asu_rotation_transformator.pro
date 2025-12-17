function asu_rotation_transformator, grid_size, angle
compile_opt idl2

nx = grid_size[0]
ny = grid_size[1]
cs = cos(angle*!DTOR)
ss = sin(angle*!DTOR)
dxl = ny*ss 
dxr = nx*cs
dyb = nx*ss
dyt = ny*cs

if angle lt 0 then begin
    x0 = dxl
    y0 = 0
endif else begin
    x0 = 0
    y0 = -dyb
endelse

nnx = ceil(dxr + abs(dxl))
nny = ceil(abs(dyb) + dyt)

grid_x = dblarr(nnx, nny)
grid_y = dblarr(nnx, nny)
for k = 0, nny-1 do begin
    grid_x[*, k] = dindgen(nnx) + x0
endfor
for k = 0, nnx-1 do begin
    grid_y[k, *] = dindgen(nny) + y0
endfor

cs = cos(angle*!DTOR)
ss = sin(angle*!DTOR)

xn = grid_x*cs - grid_y*ss
yn = grid_x*ss + grid_y*cs

return, {angle:angle, cs:cs, ss:ss, x0:x0, y0:y0, xt:xn, yt:yn}

end
