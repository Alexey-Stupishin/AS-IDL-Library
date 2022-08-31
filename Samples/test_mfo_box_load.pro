pro test_mfo_box_load


mfo_box_load $
           , '2020-12-28 10:00:00', '12794', [-150, -50], [185, 290], 500, 'g:\BIGData\UData\SDOBoxes', 'g:\BIGData\UCache\HMI' $ ; [-150, -50] and 500 km is optimal choice for this region
;           , /save_pbox $
;           
;           , /aia_uv $ ; all uv channels, ['1600', '1700'] or [1600, 1700] 
;              or
;           , aia_uv = [1600] $ ; etc., selected euv channels
;           
;           , /aia_euv $ ; all euv channels, ['171', '193', '211', '94', '131', '304', '335'] or [171, 193, 211, 94, 131, 304, 335]
;              or
;           , aia_euv = [171, 193] $ ; etc., selected euv channels
;           
;           , /no_NLFFF $
;           , /ask_NLFFF $

;           , version_info = version_info $ ; temporary not implemented
           , NLFFF_filename = NLFFF_filename$


; print, version_info ; temporary not implemented

setenv, 'mfo_NLFFF_filename=' + NLFFF_filename

end
