pro test_mfo_box_load

mfo_box_load $
           , '2015-12-18 13:00:00', '12470', [-150, -50], [185, 290], 2000, 'c:\temp\SDOBoxes', 'c:\temp\SDOCache' $
            , NLFFF_filename = NLFFF_filename $
;            , aia_uv = 1 $
;            , aia_euv = 1 $
            , version_info = version_info

print, version_info

setenv, 'mfo_NLFFF_filename=' + NLFFF_filename

end
