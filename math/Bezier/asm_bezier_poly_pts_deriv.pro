function asm_bezier_poly_pts_deriv, t, p

derv = dblarr(3)
derv[0] = 3*(p[1]-p[0])
derv[1] = 6*(p[0] - 2*p[1] + p[2])
derv[2] = 3*(-p[0] + 3*p[1] - 3*p[2] + p[3])

return, derv

end
