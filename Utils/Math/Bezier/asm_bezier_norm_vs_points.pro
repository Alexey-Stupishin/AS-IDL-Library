pro asm_bezier_norm_vs_points, norm, points, transf_dir
compile_opt idl2

M = [[ 1, -3,  3, -1 ] $
   , [ 0,  3, -6,  3] $
   , [ 0,  0,  3, -3] $
   , [ 0,  0,  0,  1] $
    ]

if transf_dir eq 0 then begin ; polynoms 2 points
    MI = invert(M)
    px = MI # norm.x_poly
    py = MI # norm.y_poly
    points = dblarr(2, 4)
    points[0, *] = px
    points[1, *] = py
endif else begin
    nx = M # transpose(points[0, *], [1, 0])
    ny = M # transpose(points[1, *], [1, 0])
    norm = {x_poly:nx, y_poly:ny}
endelse        

end
