function asm_bezier_markup_eqv_mindist, x, y, xt, yt

smach = machar(/double)
mind = smach.xmax
for k = 0, n_elements(x)-1 do begin
    mind = min([mind, norm([x[k]-xt, y[k]-yt])])
endfor

return, mind

end

function asm_bezier_markup_eqv, polys, tlim, step, hwidth, x = x, y = y, maxdist = maxdist, eps = eps, vdiv = vdiv, vmult = vmult

if n_elements(maxdist) eq 0 then maxdist = 0d

data = asm_bezier_markup_curve_eqv(polys, tlim, step[0], eps = eps, vdiv = vdiv, vmult = vmult)

sz = size(data)
lng = !NULL
if n_elements(x) gt 0 && n_elements(x) eq n_elements(y) then begin
    isin = intarr(sz[2])
    for k = 0, sz[2]-1 do begin
        xt = poly(data[2, k], polys.x_poly)
        yt = poly(data[2, k], polys.y_poly)
        tdist = asm_bezier_markup_eqv_mindist(x, y, xt, yt)
        isin[k] = tdist lt maxdist
        if k eq 65 then begin
            stophere = 1
        endif
    endfor
    idx = where(isin ne 0, count)
    if count lt sz[2] then begin
        from = min(idx)
        to = max(idx)
        lng = to - from + 1
    endif
endif
    
if lng eq !NULL then begin
    from = 0
    to = sz[2]-1
    lng = sz[2]
endif

x_grid = dblarr(2*hwidth+1, lng)
y_grid = dblarr(2*hwidth+1, lng)
s = step[1]

x_deriv = asm_bezier_get_deriv(polys.x_poly)
y_deriv = asm_bezier_get_deriv(polys.y_poly)
for k = from, to do begin
    v = data[0:1, k]
    C = [poly(data[2, k], x_deriv), poly(data[2, k], y_deriv)]
    C = C/norm(C)
    
    for p = 0, 2*hwidth do begin
        dp = (p-hwidth)*s
        x_grid[p, k-from] = v[0] + dp*C[1] 
        y_grid[p, k-from] = v[1] - dp*C[0] 
    endfor
    
endfor

return, {data:data, x_grid:x_grid, y_grid:y_grid}

end
