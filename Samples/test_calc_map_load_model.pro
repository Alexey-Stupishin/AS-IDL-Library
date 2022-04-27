pro test_calc_map_load_model, file, mult, rsun, dist, up, ps, box, model_mask, model 

restore, file
vcos = [sin(dist*!DTOR), 0d, 1d]
vcos[2] = sqrt(1d - vcos[0]^2 - vcos[1]^2)
up = 0.43d 
ps = 0.045d 

box.bx *= mult
box.by *= mult
box.bz *= mult
posangle = 0
vbox = box
box = {bx:vbox.bx, by:vbox.by, bz:vbox.bz, modstep:vbox.modstep, rsun:rsun, vcos:vcos}
sz = size(box.bx)
model_mask = lonarr(sz[1], sz[2])
model_mask[*, *] = 1
bz = abs(box.bz[*, *, 0])
zmax = max(bz)
idx = where(bz gt zmax*ps, count)
if count gt 0 then model_mask[idx] = 6
idx = where(bz gt zmax*up, count)
if count gt 0 then model_mask[idx] = 7
model = 1

end
