pro asu_plain_to_box, date_obs, fpath, ID, cont_file, mag_file, scale, depth, z_factor, pot = pot 

infile = fpath + ID + '.sav'

base = sst_to_photosphere(date_obs, infile, scale, depth, i0 = i0, wcs0 = wcs0, wcsR = wcsR, dr = dr)

sz = size(base.bx)

sst_to_cube, ID, base, wcs0, wcsR, z_factor, depth, dr, cont_file, mag_file, box = box, pbox = pbox, exboxdata = exboxdata

asu_box_aia_from_box, box, daia
ID += '_' + asu_compstr(sz[1]) + 'x' + asu_compstr(sz[2])

bndid = fpath + ID + '_BND'
box.id = id
save, filename = bndid + '.sav', box
message, 'BND saved', /info

asu_box_create_mfodata, mfodata, box, box, daia, exboxdata, bndid
asuml_sst2sst_separate, mfodata, data, bx, by, bz
save, file = bndid + '_index.sav', data
save, file = bndid + '_bx.sav', bx
save, file = bndid + '_by.sav', by
save, file = bndid + '_bz.sav', bz
message, 'BND_SST saved', /info

if n_elements(pot) ne 0 then begin
    sbox = box
    box = pbox
    potid = fpath + ID + '_POT'
    save, filename = potid + '.sav', box
    message, 'POT saved', /info
    
    asu_box_create_mfodata, mfodata, pbox, sbox, daia, exboxdata, potid
    asuml_sst2sst_separate, mfodata, data, bx, by, bz
    save, file = potid + '_index.sav', data
    save, file = potid + '_bx.sav', bx
    save, file = potid + '_by.sav', by
    save, file = potid + '_bz.sav', bz
    message, 'POT_SST saved', /info
endif

end
