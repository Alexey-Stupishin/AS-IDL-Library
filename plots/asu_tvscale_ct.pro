; asu_tvscale_ct
; tvscale-like utility with axes, titles, and specific colortable
;
; v 1.1.24.131 (rev.807)
;
; Parameters description (see also section Comments below):
;
; Parameters required (in):
;   image2show  (2-D numeric)            - image (N x M)
;   x_arg       (2 elements numeric)     - x-axe physical values, default 0...N
;   y_arg       (2 elements numeric)     - x-axe physical values, default 0...M
;
; Parameters optional (in):
; common parameters
;   abs_bottom  (color-definition)       - background color 
;   abs_top     (color-definition)       - foreground color (for axes and titles)
;   _extra      (various types)          - Direct Graphics keyword, applicable to contour procedure
;   
; "category" colortable for discret data (bottom, center, top, contrast ignored)
;   step_colors (color-definition array) - colors corresponding to each "category" value in the image (see step_values) 
;                                          default is ['black', 'darkgray', 'gray', 'lightgray', 'white']
;                                          for color-definition see Comment (*).
;   step_values (numeric array)          - "category" values (same length as step_colors)
;                                          step_colors[0] corresponds to step_values[0] etc.
;                                          default 0...n_elements(step_colors)-1
;   ne_color    (color-definition)       - color for the categories out of step_values (abs_top by default) 
;   
; "asymmetric" colortable for "continuous" data (step_colors, step_values, ne_color ignored)
;   bottom      (color-definition)       - bottom, center, right: colors for "asymmetric" colortable
;                                          bottom for nrgative values, center for 0, top for positive values
;                                          default 'blue', 'white', 'red' (compass-like colors for magnetic field)
;   center      (color-definition)       -
;   top         (color-definition)       -
;   contrast    (real)                   - scale contrast (default 0.8) 
; 
; Parameters optional (out):
;   outimage    (2-D byte)               - image scaled to 0...255
;   colortab    (byte 3x256 array)       - applied colortab 
;
; Comments:
;   (*)   'color-definition' might be either description string (list of available colors see in asu_colortable_create_parse.pro), or
;         3-elements byte array, as described for colortable 
;         List of available description string for named colors see in asu_colortable_create_parse.pro
;
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2024
;     mailto:agstup@yandex.ru
;
;---------------------------------------------------------------------------;
;             I will battle for the Sun                                     ;
;     \|/     And I won’t stop until I’m done                      \|/      ;
;    --O--                                                        --O--     ;
;     /|\                                             Placebo      /|\      ;
;                                  "Battle for the Sun", 2009               ;
;---------------------------------------------------------------------------;
;
;-------------------------------------------------------------------------------------------------
pro asu_tvscale_ct, image2show, x_arg, y_arg $
    , abs_bottom = abs_bottom, abs_top = abs_top $
    , step_colors = step_colors, ne_color = ne_color, step_values = step_values  $
    , bottom = bottom, center = center, top = top, contrast = contrast $
    , outimage = img, colortab = colortab $
    , _extra = _extra

    compile_opt idl2

    sz = size(image2show)
    default, x_arg, indgen(sz[1]+1)
    default, y_arg, indgen(sz[2]+1)
    default, abs_bottom, 'black'
    default, abs_top, 'white'
    if n_elements(step_colors) ne 0 then begin
        if isa(step_colors, /number) && n_elements(step_colors) eq 1 then step_colors = ['black', 'darkgray', 'gray', 'lightgray', 'white']
        default, ne_color, abs_top
        use_colors = [step_colors, ne_color]
        asu_colortable_create, step_colors = use_colors, abs_bottom = abs_bottom, abs_top = abs_top, rb = rb, gb = gb, bb = bb, /load
        cm_asymm = 1
        
        n_colors = n_elements(use_colors)
        default, step_values, indgen(n_colors)
        use_image = intarr(sz[1], sz[2]) + (n_colors-1)
        for k = 0, n_colors-2 do begin
            idx = where(image2show eq step_values[k], count)
            if count gt 0 then begin
                use_image[idx] = k
            endif
        end
        ct_minmax = [0, n_colors-1]
    endif else begin
        default, bottom,   'red'
        default, center,   'white'
        default, top,      'blue'
        default, contrast, 0.8
        asu_colortable_create, bottom = bottom, center = center, top = top, abs_bottom = abs_bottom, abs_top = abs_top, rb = rb, gb = gb, bb = bb, /load
        cm_symm = 1
        use_image = image2show
    endelse

    colortab = [transpose(bb), transpose(gb), transpose(rb)]
    
    asu_tvscale, use_image, x_arg, y_arg $
        , axis_color_idx = 255, bkgr_color_idx = 0 $
        , cm_symm = cm_symm, cm_asymm = cm_asymm $
        , n_colors = n_colors, ct_minmax = ct_minmax $
        , outimage = img, xout = xout, yout = yout $
        , _extra = _extra
end