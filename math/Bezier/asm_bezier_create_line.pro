function asm_bezier_create_line, reper_pts, points = points
compile_opt idl2

if n_elements(points) eq 0 then points = 100 
 
tset = asu_linspace(0d, 1d, points)
xy = dblarr(2, points)
for k = 0, points-1 do begin
    xy[0, k] = asm_bezier_poly_pts(tset[k], reper_pts[0, *])
    xy[1, k] = asm_bezier_poly_pts(tset[k], reper_pts[1, *])
endfor

return, xy

end
