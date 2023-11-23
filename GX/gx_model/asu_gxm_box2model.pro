function asu_gxm_box2model, box, tr_height_km = tr_height_km, reduce_passed = reduce_passed, lib_path = lib_path

default, tr_height_km, 1000

model = box

gx_addlines2box, model, tr_height_km, reduce_passed = reduce_passed, lib_path = lib_path

chromo_mask = decompose(box.base.bz, box.base.ic)
model = combo_model(model, chromo_mask)

return, model

end
