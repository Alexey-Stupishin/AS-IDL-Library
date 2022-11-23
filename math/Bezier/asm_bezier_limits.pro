function asm_bezier_limits_get, v, v_poly

sz = size(v_poly)
bnd = dblarr(sz[1])
bnd[0] = min(v)
rmin = fz_roots(v_poly - bnd)
bnd[0] = max(v)
rmax = fz_roots(v_poly - bnd)

rr = [rmin, rmax]

s = machar(/double)
tlim = [s.xmax, -s.xmax]

for k = 0, n_elements(rr)-1 do begin
    if imaginary(rr[k]) eq 0 then begin
        tlim[0] = min([tlim[0], rr[k]])
        tlim[1] = max([tlim[1], rr[k]])
    endif    
endfor

return, tlim

end

function asm_bezier_limits, x, y, x_poly, y_poly, maxdist = maxdist

xlim = minmax(x)
ylim = minmax(y)

If n_elements(x_poly) eq 2 then maxdist *= 5 

tlimx = asm_bezier_limits_get(xlim, x_poly)
tlimy = asm_bezier_limits_get(ylim, y_poly)
tlim = tlimx
tlim[0] = max([tlim[0], tlimy[0]])
tlim[1] = min([tlim[1], tlimy[1]])

ntest = 1000
t = asu_linspace(tlim[0], tlim[1], ntest)
dists = dblarr(ntest)
for k = 0, ntest-1 do begin
    xt = poly(t[k], x_poly)
    yt = poly(t[k], y_poly)
    for kp = 0, n_elements(x)-1 do begin
        dists[k] = norm([x[kp]-xt, y[kp]-yt])
    endfor    
endfor
idxs = where(dists < maxdist, count)
if count ne 0 then begin
    tlim[0] = t[idxs[0]]
    tlim[1] = t[idxs[-1]]
end

return, tlim

end
