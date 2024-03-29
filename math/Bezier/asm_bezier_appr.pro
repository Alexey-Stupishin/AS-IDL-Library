pro asm_bezier_bound, xin, x
    x = xin
end

function asm_bezier_crit, x, f, context
    m = mean(x[*, 0:context.order], dimension = 1)
    d = stddev(x[*, 0:context.order], dimension = 1)
    sum = total(d/m ge context.tolerance) ; + total(stddev(f, dimension = 1)/mean(f, dimension = 1) ge 1e-3)
    
    return, sum eq 0
end
    
function asm_bezier_appr, x00, y00, order, result, iter, tolerance = tolerance, init = init, dinit = dinit, simpseed = simpseed, tlims = tlims, maxiter = maxiter, err = err

if n_elements(dinit) eq 0 then dinit = 0.01d
if n_elements(tolerance) eq 0 then tolerance = 1d-5

err = 0

x0 = double(x00)
y0 = double(y00)
x0 -= mean(x0)
y0 -= mean(y0)

if n_elements(init) eq 0 then begin
   
    simpseed = dblarr(8)
    if order eq 1 and n_elements(x0) eq 2 then begin
        simpseed[0] = x0[0]
        simpseed[1] = x0[1] - x0[0]
        simpseed[4] = y0[0]
        simpseed[5] = y0[1] - y0[0]
        tlim = [0, 1]
    endif else begin    
        irc_principale_comps, x0, y0, vx, vy, caspect = caspect, vbeta = vbeta, rotx = rotx, roty = roty, waspect = waspect, baspect = baspect, tot_lng = tot_lng, av_width = av_width
        
        resXY = dblarr(4)
        resYX = dblarr(4)
        resXY[0:order] = POLY_FIT(rotx, roty, order, CHISQ = chisqXY, COVAR = covXY)
        resYX[0:order] = POLY_FIT(roty, rotx, order, CHISQ = chisqYX, COVAR = covYX)
        
        coefs = dblarr(2, 4)
        if chisqXY lt chisqYX then begin 
            coefs[0, *] = [0, 1, 0, 0]
            coefs[1, *] = resXY
            tlim = minmax(rotx) 
            sord = sort(rotx)
        endif else begin
            coefs[0, *] = resYX 
            coefs[1, *] = [0, 1, 0, 0] 
            tlim = minmax(roty) 
            sord = sort(roty)
        endelse
        x0 = x0[sord]    
        y0 = y0[sord]
            
        sb = sin(vbeta)
        cb = cos(vbeta)
        for k = 0, 3 do begin
            simpseed[k  ] = cb*coefs[0, k] - sb*coefs[1, k] 
            simpseed[k+4] = sb*coefs[0, k] + cb*coefs[1, k] 
        endfor
    endelse
endif else begin
    simpseed = init
    simpseed[0] -= mean(x00)
    simpseed[4] -= mean(y00)
    ; !!! NB! tlim ???
endelse

context = {x:x0, y:y0, order:order, tlim:tlim, tolerance:tolerance}

if order gt 1 then begin    
    simp = dblarr(9, 8)
    
    simp[0, *] = simpseed*(1d - dinit)
    v = simpseed * 2d * dinit
    
    simp[1, *] = simp[0, *] + [v[0],    0,    0,    0,    0,    0,    0,    0]
    simp[2, *] = simp[0, *] + [   0, v[1],    0,    0,    0,    0,    0,    0]
    simp[3, *] = simp[0, *] + [   0,    0, v[2],    0,    0,    0,    0,    0]
    simp[4, *] = simp[0, *] + [   0,    0,    0, v[3],    0,    0,    0,    0]
    simp[5, *] = simp[0, *] + [   0,    0,    0,    0, v[4],    0,    0,    0]
    simp[6, *] = simp[0, *] + [   0,    0,    0,    0,    0, v[5],    0,    0]
    simp[7, *] = simp[0, *] + [   0,    0,    0,    0,    0,    0, v[6],    0]
    simp[8, *] = simp[0, *] + [   0,    0,    0,    0,    0,    0,    0, v[7]]
    
    err = asm_neldermead('asm_bezier_calc', 'asm_bezier_crit', 'asm_bezier_bound', context, simp, solution, iter, maxiter = maxiter)
endif else begin
    err = 0
    iter = 0
    solution = simpseed
endelse

if err ne 0 then return, 0

resid = asm_bezier_calc(solution, context, troots = troots, dists = dists, tstack = tstack)

s = machar(/double)
tlims = [s.xmax, -s.xmax]
for k = 0, n_elements(tstack)-1 do begin
    t = troots[tstack[k], k]
    tlims[0] = tlims[0] < t
    tlims[1] = tlims[1] > t
endfor    

solution[0] += mean(x00)
solution[4] += mean(y00)
simpseed[0] += mean(x00)
simpseed[4] += mean(y00)

;result = {x_poly:solution[0:order], y_poly:solution[4:4+order]}
result = asm_bezier_normalize(solution, tlims)
tlims = [0, 1]

return, max(dists)

end