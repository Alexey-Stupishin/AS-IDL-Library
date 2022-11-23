function asm_bezier_markup_normals, polys, tset, step, hwidth

nt = n_elements(tset)

x_grid = dblarr(2*hwidth+1, nt)
y_grid = dblarr(2*hwidth+1, nt)

x_deriv = asm_bezier_get_deriv(polys.x_poly)
y_deriv = asm_bezier_get_deriv(polys.y_poly)

for k = 0, nt-1 do begin
    xy = [poly(tset[k], polys.x_poly), poly(tset[k], polys.y_poly)]
    C = [poly(tset[k], x_deriv), poly(tset[k], y_deriv)]
    C = C/norm(C)
    
    for p = 0, 2*hwidth do begin
        dp = (p-hwidth)*step
        x_grid[p, k] = xy[0] + dp*C[1] 
        y_grid[p, k] = xy[1] - dp*C[0] 
    endfor
endfor

return, {x_grid:x_grid, y_grid:y_grid}

end
