function asm_bezier_get_deriv, v_poly

v_deriv = v_poly[1:*]
sz = size(v_deriv)
mult = indgen(sz) + 1

return, v_deriv * mult

end
