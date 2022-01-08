function asm_bezier_markup_eqv, polys, tlim, step, hwidth, eps = eps, vdiv = vdiv, vmult = vmult

data = asm_bezier_markup_curve_eqv(polys, tlim, step[0], eps = eps, vdiv = vdiv, vmult = vmult)

sz = size(data)
x_grid = dblarr(2*hwidth+1, sz[2])
y_grid = dblarr(2*hwidth+1, sz[2])
s = step[1]

x_deriv = asm_bezier_get_deriv(polys.x_poly)
y_deriv = asm_bezier_get_deriv(polys.y_poly)
for k = 0, sz[2]-1 do begin
    ;v = [poly(data[2, k], polys.x_poly), poly(data[2, k], polys.y_poly)]
    v = data[0:1, k]
    C = [poly(data[2, k], x_deriv), poly(data[2, k], y_deriv)]
    C = C/norm(C)
    ; B = C[0]*v[0] + C[1]*v[1]
    ; Cx*x + Cy*y = B = Cx*v[0] + Cy*v[1]
    
    for p = 0, 2*hwidth do begin
        dp = (p-hwidth)*s
        x_grid[p, k] = v[0] + dp*C[1] 
        y_grid[p, k] = v[1] - dp*C[0] 
    endfor
    
endfor

return, {data:data, x_grid:x_grid, y_grid:y_grid}

end
