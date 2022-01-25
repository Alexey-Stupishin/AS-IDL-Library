pro asm_bezier_calc_body, x, context, r, nroots, troots, dists
    ndata = n_elements(context.x)
    nroots = intarr(ndata)
    troots = dblarr(5, ndata)
    dists = dblarr(5, ndata)
    for k = 0, ndata-1 do begin
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
        for p = 0, n_elements(roots)-1 do begin
            if imaginary(roots[p]) eq 0 then begin
                vx = poly(roots[p], x[0:3])
                vy = poly(roots[p], x[4:7])
                vv = norm([context.x[k]-vx, context.y[k]-vy])
                troots[nroots[k], k] = real_part(roots[p])
                dists[nroots[k], k] = vv
                nroots[k]++
            endif
        endfor
    endfor
end

function asm_bezier_calc, x, context, dists = dists

    r = dblarr(6)
    r[1] = -x[1]*x[1] -x[5]*x[5]
    if context.order gt 1 then begin
        r[2] = -3*(x[1]*x[2] + x[5]*x[6])
        r[3] = -2*(x[2]*x[2] + x[6]*x[6])
        if context.order gt 2 then begin
            r[3] += -4*(x[1]*x[3] + x[5]*x[7])
            r[4] = -5*(x[2]*x[3] + x[6]*x[7])
            r[5] = -3*(x[3]*x[3] + x[7]*x[7])
        endif
    endif
    
    ndata = n_elements(context.x)
    dists = dblarr(ndata)
    tpars = dblarr(ndata)
    asm_bezier_calc_body, x, context, r, nroots, troots, dists
    s = asm_bezier_find_opt_solution(nroots, troots, dists)
    
    return, s
end
