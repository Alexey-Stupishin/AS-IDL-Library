pro sst_decimate, filename, step = step

if n_elements(step) eq 0 then step = 2

restore, filename 

sz = size(box.bx)
idx = box.index

if step ne 1 then begin
    base = {bx:box.base.bx[0:*:step, 0:*:step], by:box.base.by[0:*:step, 0:*:step], bz:box.base.bz[0:*:step, 0:*:step], ic:box.base.ic[0:*:step, 0:*:step]}
    
    bx = box.bx[0:*:step, 0:*:step, 0:*:step]
    by = box.by[0:*:step, 0:*:step, 0:*:step]
    bz = box.bz[0:*:step, 0:*:step, 0:*:step]
    
    dr = box.dr*step
    szd = size(bx)
    
    idx.cdelt1 = box.index.cdelt1*step
    idx.cdelt2 = box.index.cdelt2*step
    idx.crpix1 = (box.index.crpix1+1)/step
    idx.crpix2 = (box.index.crpix2+1)/step
    idx.naxis1 = szd[1]
    idx.naxis2 = szd[2]
    
    parse = stregex(box.id, '(.*_)([0-9]*)x([0-9]*)(.*)',/subexpr,/extract)
    id = parse[1] + asu_compstr(szd[1]) + 'x' + asu_compstr(szd[2]) + parse[4] 
    fpathn = strpos(filename,'\', /REVERSE_SEARCH)
    filename = strmid(filename, 0, fpathn+1) + id + '.sav'
endif else begin
    base = box.base
    bx = box.bx
    by = box.by
    bz = box.bz
    dr = box.dr
    id = box.id
endelse

box = {ADD_BASE_LAYER:box.ADD_BASE_LAYER, base:base, bx:bx, by:by, bz:bz, dr:dr, execute:'', id:id, index:idx, refmaps:box.refmaps}

box.execute = sst_get_execute(box)

save, filename = filename, box

end
