pro sst_to_cube, ID, base0, wcs0, wcs, z_factor, depth, dr, continuum, magnetogram, box = box, pbox = pbox, exboxdata = exboxdata 

t0 = systime(/seconds)

read_sdo, continuum, index, data, /uncomp_delete
wcs0 = FITSHEAD2WCS(index[0])
wcs2map, data, wcs0, map
map2wcs, map, wcs0
ic = wcs_remap(data, wcs0, wcs, /ssaa)

base = {bx:base0.bx, by:base0.by, bz:base0.bz, ic:ic}

sz = size(base0.bx)
size_pix = lonarr(3)
size_pix[0] = sz[1]
size_pix[1] = sz[2]
size_pix[2] = sst_to_box_ext(floor(max(size_pix[0:1])*z_factor), depth)

refmaps = obj_new('map')
box = {bx:dblarr(size_pix), by:dblarr(size_pix), bz:dblarr(size_pix) $
    , dr:dr, add_base_layer:0, base:base, index:wcs2fitshead(wcs, /structure) $
    , execute:'', refmaps: ptr_new(refmaps), id:ID} 
box.bx[*,*,0] = base.bx
box.by[*,*,0] = base.by
box.bz[*,*,0] = base.bz

gx_box_add_refmap, box, continuum, id = 'Continuum'
gx_box_add_refmap, box, magnetogram, id = 'LOS_magnetogram'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gx_box_add_vertical_current_map, box, files.field, files.inclination, files.azimuth, files.disambig
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

box.execute = sst_get_execute(box)

message, 'prepare complete in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
gx_box_make_potential_field, box, pbox
message, 'potential complete in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

asu_box_get_coord, box, exboxdata

end
