pro asu_box_create_mfodata, mfodata, data, box, aia, boxdata, fileid, version_info=version_info, input_coords=input_coords

if not keyword_set(version_info) then begin
    version_info = 'none'
endif
if not keyword_set(input_coords) then begin
    input_coords = {x:0, y:0}
endif

magnetogram = 0
refmaps=*(box.Refmaps())
for i=0, refmaps->get(/count)-1 do begin
    if refmaps->get(i,/id) eq 'LOS_magnetogram' then begin
        magnetogram = refmaps->get(i,/map)
        break
    endif
endfor

model_mask = decompose(box.base.bz, box.base.ic)

vcos = boxdata.vcos
vcos[0:1] = reverse(vcos[0:1])
mfodata = {  sst_version:'20200228' $
           , bx:transpose(data.by, [1, 0, 2]), by:transpose(data.bx, [1, 0, 2]), bz:transpose(data.bz, [1, 0, 2]) $
           , ic:transpose(box.base.ic, [1, 0]), magn:magnetogram.data, model_mask:transpose(model_mask, [1, 0]) $
           , obstime:box.index.date_obs, fileid:fileid $
           , x_box:transpose(boxdata.y_box, [1, 0]), y_box:transpose(boxdata.x_box, [1, 0]) $
           , dkm:boxdata.dkm, dx_arc:boxdata.dy*boxdata.rsun, dy_arc:boxdata.dx*boxdata.rsun $
           , x_cen:boxdata.y_cen, y_cen:boxdata.x_cen, R_arc:boxdata.rsun $
           , lon_cen:boxdata.lon_cen, lat_cen:boxdata.lat_cen $
           , vcos:vcos $
           , lon_hg:transpose(boxdata.lon_hg, [1, 0]), lat_hg:transpose(boxdata.lat_hg, [1, 0]) $
           , input_x:input_coords.y, input_y:input_coords.x $
           , aia_ids:aia.ids, aia_data:aia.data, aia_size:aia.size, aia_center:aia.center, aia_step:aia.step, aia_RSun:aia.RSun $
           , version_info:version_info $
                  }
end
