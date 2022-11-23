pro asuml_xyz2gxbox, sourcepath, destpath

restore, sourcepath
;hmi.M_720s.20120711_022226.W82S16CR.CEA.NAS.T3D_exact_0.3(ML).sav 
restore, destpath
;hmi.M_720s.20120711_022226.W82S16CR.CEA.NAS.sav 

box.bx = transpose(by, [1, 0, 2])
box.by = transpose(bx, [1, 0, 2])
box.bz = transpose(bz, [1, 0, 2])
;box.bx = bx
;box.by = by
;box.bz = bz

;expr_src = stregex(destpath,'(.+)\.NAS\.(.*)\(ML\)\.sav',/subexpr,/extract)  
expr_src = stregex(sourcepath,'(.+)\.BND_sst.sav_(.*)\(ML\)\.sav',/subexpr,/extract)  
outname = expr_src[1] + '.NAS.' + expr_src[2] + '.sav'  

save, filename = outname, box    
  
end
