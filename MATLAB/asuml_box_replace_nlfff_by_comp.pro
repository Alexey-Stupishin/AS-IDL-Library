pro asuml_box_replace_nlfff_by_comp, boxpath, nlfffpattern, save_comp = save_comp 

restore, boxpath ; box

;execstr = sst_get_execute(box)
;box = create_struct(box, create_struct('EXECUTE', execstr))

if n_elements(save_comp) ne 0 then begin
    restore, nlfffpattern + '_bx(ML).sav'
    restore, nlfffpattern + '_by(ML).sav'
    restore, nlfffpattern + '_bz(ML).sav'
    box.bx = bx
    box.by = by
    box.bz = bz
endif else begin
    restore, nlfffpattern + '.sav'
endelse

box.id += '_NAS'
 
parser = stregex(boxpath, '(.+)\\(.+)',/subexpr,/extract,/fold_case)
outname = parser[1] + '\' + box.id + '.sav'
save, filename = outname, box    
  
box.id += '_sst'
asu_box_get_coord, box, boxdata
asu_box_aia_from_box, box, aia
asu_box_create_mfodata, mfodata, box, box, aia, boxdata, box.id

out = parser[1] + '\' + box.id
if n_elements(save_comp) ne 0 then begin
    asuml_sst2sst_separate, mfodata, data, bx, by, bz
    save, file = out + '_index.sav', data
    save, file = out + '_bx.sav', bx
    save, file = out + '_by.sav', by
    save, file = out + '_bz.sav', bz
endif else begin
    save, file = out + '.sav', mfodata
endelse
  
end
