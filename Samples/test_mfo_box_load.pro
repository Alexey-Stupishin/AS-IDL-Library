pro test_mfo_box_load

mfo_box_load $
           , '2015-12-18 13:00:00', '12470', [-100, 0], [185, 290], 1000, 'g:\BIGData\UData\SDOBoxes', 'g:\BIGData\UCache\HMI' $ ; but [-150, -50] and 500 km is optimal choice
;           , /no_sel_check
;           , /save_pbox $
;           , /aia_uv $
;           , /aia_euv $
;           , /no_NLFFF $
           , /ask_NLFFF $
           , NLFFF_filename = NLFFF_filename $
           , version_info = version_info

print, version_info

setenv, 'mfo_NLFFF_filename=' + NLFFF_filename

end
