function asuml_box2sst, box

setenv, 'WCS_RSUN=6.96d8'
asu_box_get_coord, box, boxdata
asu_box_aia_from_box, box, aia
asu_box_create_mfodata, mfodata, box, box, aia, boxdata, box.id

return, mfodata

end
