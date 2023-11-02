pro asuml_box_replace_nlfff, boxpath, nlfffpath

restore, boxpath ; box
restore, nlfffpath ; bx, by, bz

; expr = stregex(box.id,'(.+)\.([A-Z]+)',/subexpr,/extract)  
; box.id = expr[1] + '.NAS'
box.id += '_NAS'

box.bx = bx
box.by = by
box.bz = bz
 
parser = stregex(boxpath, '(.+)\\(.+)',/subexpr,/extract,/fold_case)
outname = parser[1] + '\' + box.id + '.sav'
save, filename = outname, box    
  
box.id += '_sst'
asu_box_get_coord, box, boxdata
asu_box_aia_from_box, box, aia
asu_box_create_mfodata, mfodata, box, box, aia, boxdata, box.id
save, file = parser[1] + '\' + box.id + '.sav', mfodata
  
end
