pro test_jet2hmi_conveyer

;n = jet2hmi_conveyer('20100916_235930_20100917_005930_57_-511_500_500' $
;                   , '/home/stupishin/coronal_jets/Jets/20100916_235930_20100917_005930_57_-511_500_500/objects_m2/171.sav' $
;                   , '/home/stupishin/coronal_jets/Jets/20100916_235930_20100917_005930_57_-511_500_500/objects_m2/171.csv' $
;                   , '/home/stupishin/coronal_jets/Jets/out.sav', '/home/stupishin/coronal_jets/Jets/out.png' $
;                   , boxespath = '/home/stupishin/coronal_jets/hmi_take_2/hmi_boxes' $
;                   , cachepath = '/home/stupishin/hmi_cache' $
;                   )

params = {init_fov:300, b_check:1400, dx_maxsize:300, dsize:200, smed:25, ssmth:25, Bmaxlim:5000, Bminlim:80, exstep:50, exlim:50}

n = jet2hmi_conveyer('20111211_112500_20111211_133700_-543_-319_500_500' $
   , params $
   , '/home/stupishin/coronal_jets/hmi_take_2/jets4hmi/20111211_112500_20111211_133700_-543_-319_500_500/objects_m2/171.sav' $
   , '/home/stupishin/coronal_jets/hmi_take_2/jets4hmi/20111211_112500_20111211_133700_-543_-319_500_500/objects_m2/171.csv' $
   , '/home/stupishin/coronal_jets/hmi_take_2/hmi_data' $
   , '/home/stupishin/coronal_jets/hmi_take_2/hmi_images' $
   , '/home/stupishin/coronal_jets/hmi_take_2/hmi_conf' $
   , boxespath = '/home/stupishin/coronal_jets/hmi_take_2/hmi_boxes' $
   , cachepath = '/home/stupishin/hmi_cache' $
   )
                
end
