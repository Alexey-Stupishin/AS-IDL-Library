pro asm_bezier_bound, xin, x
    x = xin
end

function asm_bezier_calc, x, context
    r = dblarr(6)
    r[1] = -x[1]*x[1] -x[5]*x[5]
    if context.order gt 1 then begin
        r[2] = -3*(x[1]*x[2] + x[5]*x[6])
        if context.order gt 2 then begin
            r[3] = -2*(2*x[1]*x[3] + x[2]*x[2] + 2*x[5]*x[7] + x[6]*x[6])
            r[4] = -5*(x[2]*x[3] + x[6]*x[7])
            r[5] = -3*(x[3]*x[3] + x[7]*x[7])
        endif
    endif
    s = 0
    for k = 0, n_elements(context.x)-1 do begin
        rw = r
        dx = context.x[k] - x[0] 
        dy = context.y[k] - x[4] 
        rw[0] += dx*x[1] + dy*x[5]
        if context.order gt 1 then begin
            rw[1] += 2*(dx*x[2] + dy*x[6])
            if context.order gt 2 then begin
                rw[2] += 3*(dx*x[3] + dy*x[7])
            endif
        endif
        mp = 5
        for p = mp, 0, -1 do begin
            if rw[p] ne 0 then break
        endfor
        roots = fz_roots(rw[0:p])
        dst = !NULL
        for p = 0, n_elements(roots)-1 do begin
            if imaginary(roots[p]) eq 0 then begin
                vx = poly(roots[p], x[0:3])
                vy = poly(roots[p], x[4:7])
                vv = norm([context.x[k]-vx, context.y[k]-vy])
                if dst eq !NULL then dst = vv else dst = min([dst, vv])
            endif
        endfor
        s += dst^2
    endfor
    
    return, s
end

function asm_bezier_crit, x, f
    sum = total(stddev(x, dimension = 1)/mean(x, dimension = 1) ge 1e-5) ; + total(stddev(f, dimension = 1)/mean(f, dimension = 1) ge 1e-3)
    
    return, sum eq 0
end
    
pro asm_bezier_appr, x00, y00, order, result, iter, simpseed = simpseed

x0 = double(x00)
y0 = double(y00)
x0 -= mean(x0)
y0 -= mean(y0)
pipeline_aia_irc_principale_comps, x0, y0, vx, vy, caspect = caspect, vbeta = vbeta, rotx = rotx, roty = roty, waspect = waspect, baspect = baspect, tot_lng = tot_lng, av_width = av_width

resXY = dblarr(4)
resYX = dblarr(4)
resXY[0:order] = POLY_FIT(rotx, roty, order, CHISQ = chisqXY, COVAR = covXY)
resYX[0:order] = POLY_FIT(roty, rotx, order, CHISQ = chisqYX, COVAR = covYX)

;hp = plot(x00, y00)
;hp = plot(rotx, roty)

coefs = dblarr(2, 4)
if chisqXY lt chisqYX then begin 
    coefs[0, *] = [0, 1, 0, 0]
    coefs[1, *] = resXY
endif else begin
    coefs[0, *] = resYX 
    coefs[1, *] = [0, 1, 0, 0] 
endelse
    
sb = sin(vbeta)
cb = cos(vbeta)

simpseed = dblarr(8)
for k = 0, 3 do begin
    simpseed[k  ] = cb*coefs[0, k] - sb*coefs[1, k] 
    simpseed[k+4] = sb*coefs[0, k] + cb*coefs[1, k] 
endfor

context = {x:x0, y:y0, order:order}

simp = dblarr(9, 8)

simp[0, *] = simpseed*0.95d
v = simpseed * 0.05d

simp[1, *] = simp[0, *] + [v[0],    0,    0,    0,    0,    0,    0,    0]
simp[2, *] = simp[0, *] + [   0, v[1],    0,    0,    0,    0,    0,    0]
simp[3, *] = simp[0, *] + [   0,    0, v[2],    0,    0,    0,    0,    0]
simp[4, *] = simp[0, *] + [   0,    0,    0, v[3],    0,    0,    0,    0]
simp[5, *] = simp[0, *] + [   0,    0,    0,    0, v[4],    0,    0,    0]
simp[6, *] = simp[0, *] + [   0,    0,    0,    0,    0, v[5],    0,    0]
simp[7, *] = simp[0, *] + [   0,    0,    0,    0,    0,    0, v[6],    0]
simp[8, *] = simp[0, *] + [   0,    0,    0,    0,    0,    0,    0, v[7]]

asu_neldermead, 'asm_bezier_calc', 'asm_bezier_crit', 'asm_bezier_bound', context, simp, solution, iter 
solution[0] += mean(x00)
solution[4] += mean(y00)
simpseed[0] += mean(x00)
simpseed[4] += mean(y00)

result = {x_poly:solution[0:3], y_poly:solution[4:7]}

end