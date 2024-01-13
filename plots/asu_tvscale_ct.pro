pro asu_tvscale_ct, image2show, x_arg, y_arg $
    , xtitle = xtitle, ytitle = ytitle $
    , step_colors = step_colors $
    , bottom = bottom, center = center, top = top, contrast = contrast $
    , abs_bottom = abs_bottom, abs_top = abs_top $
    , outimage = img, xout = xout, yout = yout, colortab = colortab

    default, abs_bottom, 'black'
    default, abs_top, 'white'
    if n_elements(step_colors) ne 0 then begin
        if isa(step_colors, /number) then step_colors = ['black', 'darkgray', 'gray', 'lightgray', 'white']
        asu_colortable_create, step_colors = step_colors, abs_bottom = abs_bottom, abs_top = abs_top, rb = rb, gb = gb, bb = bb, /load
        cm_asymm = 1
    endif else begin
        default, bottom,   'red'
        default, center,   'white'
        default, top,      'blue'
        default, contrast, 0.8
        asu_colortable_create, bottom = bottom, center = center, top = top, abs_bottom = abs_bottom, abs_top = abs_top, rb = rb, gb = gb, bb = bb, /load
        cm_symm = 1
    endelse

    colortab = [transpose(bb), transpose(gb), transpose(rb)]
    
    asu_tvscale, image2show, x_arg, y_arg $
        , xtitle = xtitle, ytitle = ytitle $
        , axis_color_idx = 255, bkgr_color_idx = 0 $
        , cm_symm = cm_symm, cm_asymm = cm_asymm $
        , outimage = img, xout = xout, yout = yout
end