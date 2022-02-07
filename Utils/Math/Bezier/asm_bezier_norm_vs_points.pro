pro asm_bezier_norm_vs_points, norm, points, transf_dir

M = [[ 1, -3,  3, -1 ] $
   , [ 0,  3, -6,  3] $
   , [ 0,  0,  3, -3] $
   , [ 0,  0,  0,  1] $
    ]

if transf_dir eq 0 then begin ; polynoms 2 points
    MI = invert(M)
    px = MI # norm.x_poly
    py = MI # norm.y_poly
    points = {x_pts:px, y_pts:py}
endif else begin
    nx = M # points.x_pts
    ny = M # points.y_pts
    norm = {x_poly:nx, y_pts:ny}
endelse        

end
