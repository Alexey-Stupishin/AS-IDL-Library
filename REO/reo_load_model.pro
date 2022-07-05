pro reo_load_model, file, box, mult = mult, rsun = rsun, dist = dist, umbra = umbra, penumbra = penumbra, model_mask = model_mask, model = model 

if n_elements(mult) eq 0 then mult = 1d
if n_elements(rsun) eq 0 then rsun = 950d
if n_elements(dist) eq 0 then dist = 0d
if n_elements(umbra) eq 0 then umbra = 0.43d
if n_elements(penumbra) eq 0 then penumbra = 0.045d

restore, file
vcos = [sin(dist*!DTOR), 0d, 1d]
vcos[2] = sqrt(1d - vcos[0]^2 - vcos[1]^2)

box.bx *= mult
box.by *= mult
box.bz *= mult
posangle = 0
vbox = box
box = {bx:vbox.bx, by:vbox.by, bz:vbox.bz, modstep:vbox.modstep, rsun:rsun, vcos:vcos}

if arg_present(model_mask) then begin
    sz = size(box.bx)
    model_mask = lonarr(sz[1], sz[2])
    model_mask[*, *] = 1
    bz = abs(box.bz[*, *, 0])
    zmax = max(bz)
    idx = where(bz gt zmax*ps, count)
    if count gt 0 then model_mask[idx] = 6
    idx = where(bz gt zmax*up, count)
    if count gt 0 then model_mask[idx] = 7
endif
model = 1

end
