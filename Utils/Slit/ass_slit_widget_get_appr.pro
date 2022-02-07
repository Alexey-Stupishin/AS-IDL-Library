function ass_slit_widget_get_appr, points, fit_order, norm_poly, reper_pts

np = points.Count()
x = dblarr(np) 
y = dblarr(np) 
for k = 0, np-1 do begin
    x[k] = points[k].x 
    y[k] = points[k].y 
endfor    

order = fit_order + 1
maxdist = asm_bezier_appr(x, y, order, norm_poly, iter, simpseed = simpseed, tlims = tlims)

asm_bezier_norm_vs_points, norm_poly, reper_pts, 0

return, iter

end  
