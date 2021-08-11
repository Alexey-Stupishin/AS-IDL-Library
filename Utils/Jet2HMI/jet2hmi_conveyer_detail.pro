pro jet2hmi_conveyer_detail, id, i, info, detail, frames, coords, outfile, outpict $
                           , boxespath = boxespath, cachepath = cachepath

mfo_box_load, info.tmax, id, info.x, info.y, 2000, boxespath, cachepath $
            , box = box $
            , magnetogram = magnetogram $
            , /no_sel_check $
            , /no_NLFFF $
            , size_fov = size_fov $
            , x_mag = x_mag, y_mag = y_mag, bmax = bmax $
            , /no_title_prefix



;    detail.FramePtr
;    detail.NFrames

    
end
