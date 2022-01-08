function asu_bezier_limits_get, v, v_poly

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

function asu_bezier_limits, xlim, ylim, x_poly, y_poly

tlimx = asu_bezier_limits_get(xlim, x_poly)
tlimy = asu_bezier_limits_get(ylim, y_poly)

tlim = tlimx
tlim[0] = max([tlim[0], tlimy[0]])
tlim[1] = min([tlim[1], tlimy[1]])

return, tlim

end
