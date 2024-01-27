; asu_tvscale_ct
; tvscale-like utility with axes, titles, and specific colortable
;
; v 1.0.24.115 (rev.806)
;
; Parameters description (see also section Comments below):
;
; Parameters required (in):
;   image2show  (2-D numeric)            - 
;   x_arg       (2 elements numeric)     -
;   y_arg       (2 elements numeric)     -
;
; Parameters optional (in):
;   step_colors (color-definition array) - for color-definition see Comment (*). bottom etc. ignored
;   bottom      (color-definition)       -
;   center      (color-definition)       -
;   top         (color-definition)       -
;   contrast    (real)                   -
;   abs_bottom  (color-definition)       -
;   abs_top     (color-definition)       -   
;   _extra      (various types)          - Direct Graphics keyword, applicable to contour procedure
; 
; Parameters optional (out):
;   outimage    (2-D byte)               -
;   xout        (real 1-D array)         -
;   yout        (real 1-D array)         - 
;   colortab    (byte 3x256 array)       -  
;
; Comments:
;   (*)   'color-definition' might be either description string (list of available colors see in asu_colortable_create_parse.pro), or
;         3-elements byte array, as described for colortable 
;   (*)   logic of ranged (min, max evenly distributed)
;   (*)   List of available colors see in asu_colortable_create_parse.pro
;   (***) compass colors
;
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2024
;     mailto:agstup@yandex.ru
;
;---------------------------------------------------------------------------;
;             I (5 times) will battle for the Sun (6 times)                 ;
;     \|/     And I (5 times) won’t stop until I’m done (6 times)  \|/      ;
;    --O--                                                        --O--     ;
;     /|\                                             Placebo      /|\      ;
;                                  "Battle for the Sun", 2009               ;
;---------------------------------------------------------------------------;
;
;-------------------------------------------------------------------------------------------------
pro asu_tvscale_ct, image2show, x_arg, y_arg $
    , step_colors = step_colors $
    , bottom = bottom, center = center, top = top, contrast = contrast $
    , abs_bottom = abs_bottom, abs_top = abs_top $
    , outimage = img, xout = xout, yout = yout, colortab = colortab $
    , _extra = _extra

    default, abs_bottom, 'black'
    default, abs_top, 'white'
    if n_elements(step_colors) ne 0 then begin
        if isa(step_colors, /number) && n_elements(step_colors) eq 1 then step_colors = ['black', 'darkgray', 'gray', 'lightgray', 'white']
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
        , axis_color_idx = 255, bkgr_color_idx = 0 $
        , cm_symm = cm_symm, cm_asymm = cm_asymm $
        , outimage = img, xout = xout, yout = yout $
        , _extra = _extra
end