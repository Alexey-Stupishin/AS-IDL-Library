pro jet2hmi_batch_nix_sample 

params = {init_fov:300, b_check:1400, dx_maxsize:300, dsize:200, smed:25, ssmth:25, Bmaxlim:5000, Bminlim:80, exstep:50, exlim:50}

vntot = jet2hmi_batch(  config_path = '/home/stupishin/coronal_jets/hmi_take_1/hmi_conf' $
                      , params $
                      , boxespath = '/home/stupishin/coronal_jets/hmi_take_2/hmi_boxes' $
                      , cachepath = '/home/stupishin/hmi_cache' $
                      , confoutpath = '/home/stupishin/coronal_jets/hmi_take_2/hmi_conf' $
                      , outpath = '/home/stupishin/coronal_jets/hmi_take_2/hmi_data' $
                      , pictpath = '/home/stupishin/coronal_jets/hmi_take_2/hmi_images' $
                      )

end