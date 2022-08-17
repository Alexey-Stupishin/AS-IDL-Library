pro test_mfo_box_load


mfo_box_load $
           , '2020-12-28 10:00:00', '12794', [-150, -50], [185, 290], 500, 'g:\BIGData\UData\SDOBoxes', 'g:\BIGData\UCache\HMI' $ ; [-150, -50] and 500 km is optimal choice for this region
;           , /save_pbox $
;           , /aia_uv $
;           , /aia_euv $
;           , /no_NLFFF $
;           , /ask_NLFFF $
           , NLFFF_filename = NLFFF_filename $
           , version_info = version_info


print, version_info

setenv, 'mfo_NLFFF_filename=' + NLFFF_filename

end
