pro jet2hmi_conveyer_detail, id, i, info, detail, frames, coords, outfile, outpict $
                           , boxespath = boxespath, cachepath = cachepath

x_center = fix((info.x[0]+info.x[1])/2)
y_center = fix((info.y[0]+info.y[1])/2)
x_arc = x_center + [-150, 150]
y_arc = y_center + [-150, 150]
mfo_box_load, info.tmax, id, x_arc, y_arc, 2000, boxespath, cachepath $
            , box = box $
            , /no_sel_check $
            , /no_NLFFF $
            , size_fov = size_fov $
            , x_mag = x_mag, y_mag = y_mag, bmax = bmax, full_Bz = full_Bz $
            , /no_title_prefix

; check Bmax ?

params = {dsize:200, smed:25, ssmth:25, Bmaxlim:5000, Bminlim:80, exstep:50, exlim:50}
res = jets2hmi_mag_fov(full_Bz.data, full_Bz.index, {x:x_center, y:y_center}, params, xfov, yfov)



;    detail.FramePtr
;    detail.NFrames

    
end
