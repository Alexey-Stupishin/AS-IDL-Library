function l_asm_bezier_markup_t_calc, params, dir, t, v, vp

vp = [poly(t, params.x_deriv), poly(t, params.y_deriv)] * dir

return, 0

end

function l_asm_bezier_markup_t_bound, params, v

return, 0

end

function asm_bezier_markup_t, polys, tlim, step, width

funcpar = {x_deriv:asm_bezier_get_deriv(polys.x_poly), y_deriv:asm_bezier_get_deriv(polys.y_poly)}
boundpar = 0
h = 0d
t = tlim[0]
lng = long(floor((tlim[1] - tlim[0])/step[0] + 1))
v = [poly(tlim[0], polys.x_poly), poly(tlim[0], polys.y_poly)]
data = dblarr(2, lng)

data[*, 0] = v
for k = 1, lng-1 do begin
    status = asm_RKF45('l_asm_bezier_markup_t_calc', funcpar, 'l_asm_bezier_markup_t_bound', boundpar, v, t, step[0], h)
    data[*, k] = v
end

return, data

end
