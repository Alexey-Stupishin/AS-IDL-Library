pro asu_box_get_coord, box, boxdata

wcs_box = fitshead2wcs(box.index)   ;переводим  index в формат WCS
crd_box = wcs_get_coord(wcs_box)    ;получаем координаты (в случае Top View это угловые секунды
                                    ; для наблюдателя над центром АО) для каждого пикселя
                                    ; базовой карты в основании бокса

map = (*box.REFMAPS.getlist())[0] ;достаем первую референсную карту из бокса

;------ 1 ---------------------------------------
wcs_convert_from_coord, wcs_box, crd_box, "HPC", x_arc, y_arc, /arcsec
x_box = x_arc/map.rsun
y_box = y_arc/map.rsun

x_crd_box = transpose(crd_box[0, *, *], [1, 2, 0])
y_crd_box = transpose(crd_box[1, *, *], [1, 2, 0])
sz = size(x_box)
i_cen = sz/2
crd_cen = dblarr(2)
crd_cen[0] = bilinear(x_crd_box, i_cen[1], i_cen[2])
crd_cen[1] = bilinear(y_crd_box, i_cen[1], i_cen[2])
wcs_convert_from_coord, wcs_box, crd_cen, "HPC", x_cen, y_cen, /arcsec
x_cen = x_cen/map.rsun
y_cen = y_cen/map.rsun
asu_get_hpc_latlon, x_cen, y_cen, latitude, longitude
asu_get_direction_cosine, latitude, longitude, dircos

wcs_convert_from_coord, wcs_box, crd_box, "HG", lon,lat

dx = box.dr[0]
dy = box.dr[1]
rsun = map.rsun
dkm = dx/rsun*wcs_rsun()/1000

boxdata = {x_box:x_box,y_box:y_box, x_cen:x_cen,y_cen:y_cen, lat_cen:latitude, lon_cen:longitude, vcos:dircos, lon_hg:lon,lat_hg:lat, dx:dx,dy:dy,dkm:dkm, rsun:rsun}

end
