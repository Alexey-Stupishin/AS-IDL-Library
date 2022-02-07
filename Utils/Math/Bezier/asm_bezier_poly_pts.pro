function asm_bezier_poly_pts, t, p

s = 1-t

return, ((p[3]*t + 3*s*p[2])*t + 3*s^2*p[1])*t + s^3*p[0]

end
