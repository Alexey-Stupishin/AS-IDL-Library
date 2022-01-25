function asm_bezier_markup, in_polies, x, y, step, halfwidth, maxdist = maxdist

if n_elements(bounds) eq 0 then bounds = step[1]

tlim = asm_bezier_limits(x, y, in_polies.x_poly, in_polies.y_poly, maxdist = maxdist)

return, asm_bezier_markup_eqv(in_polies, tlim, step, halfwidth, x = x, y = y, maxdist = maxdist)

end
