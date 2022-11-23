function l_asm_bezier_markup_curve_eqv_calc, t

COMMON asm_bezier_markup_eqv_common, funcpar

x = poly(t, funcpar.x_deriv)
y = poly(t, funcpar.y_deriv)

return, sqrt(x^2 + y^2)

end

function asm_bezier_markup_curve_eqv, polys, tlim, step, eps = eps, vdiv = vdiv, vmult = vmult

COMMON asm_bezier_markup_eqv_common, funcpar

if n_elements(eps) eq 0 then eps = 1d-5
if n_elements(vdiv) eq 0 then vdiv = 2d
if n_elements(vmult) eq 0 then vmult = 1.5d

funcpar = {x_deriv:asm_bezier_get_deriv(polys.x_poly), y_deriv:asm_bezier_get_deriv(polys.y_poly)}
t = tlim[0]
lng = long(floor((tlim[1] - tlim[0])/step + 1))
v = [poly(tlim[0], polys.x_poly), poly(tlim[0], polys.y_poly)]
data = dblarr(3, lng)
data[*, 0] = [v, t]

n = 1
while t lt tlim[1] do begin
    accum = 0
    h = step
    while abs(accum-step) gt eps do begin
        val = qsimp('l_asm_bezier_markup_curve_eqv_calc', t, t+h , /DOUBLE, EPS = eps)
        if accum + val gt step then begin
            h /= vdiv
        endif else begin
            accum += val
            t += h
            h *= vmult
        endelse    
    endwhile
    if t gt tlim[1] then break
    
    v = [poly(t, polys.x_poly), poly(t, polys.y_poly)]
    data[*, n] = [v, t]
    n++
    if n ge lng then begin
        data1 = dblarr(3, 2*lng)
        data1[*, 0:lng-1] = data
        lng *= 2
        data = data1
    endif
endwhile

return, data[*, 0:n-1]

end
