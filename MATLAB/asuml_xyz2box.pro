pro asuml_xyz2box, sourcepath ; , wrcpath

restore, sourcepath
;restore, wrcpath

;box.bx = transpose(by, [1, 0, 2])
;box.by = transpose(bx, [1, 0, 2])
;box.bz = transpose(bz, [1, 0, 2])

expr = stregex(box.id,'(.+)\.([A-Z]+)',/subexpr,/extract)  
box.id = expr[1] + '.NAS'

;parser = stregex(wrcpath, '(.+)\\(.+)\\(.+)\\(.+)\\(.+)\\([^(]+)\(P([LU]+)a_w([^)]+)(.+)',/subexpr,/extract,/fold_case)
;if parser[7] eq 'LU' then cond = '96' else cond = '32'
;outname = parser[1] + '\' + parser[2] + '\' + parser[3] + '\' + parser[4] + '\' + 'AS03_' + box.id + '_ic' + cond + '_' + parser[5] + '_' + parser[8] + '.sav'

;outname = sourcepath + '.wrc.sav'
;
 
parser = stregex(sourcepath, '(.+)\\(.+)',/subexpr,/extract,/fold_case)

outname = parser[1] + '\' + box.id + '.sav'

save, filename = outname, box    
  
end
