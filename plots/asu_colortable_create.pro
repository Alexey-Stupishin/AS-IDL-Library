pro asu_colortable_create, step_colors = step_colors, bottom = bottom, center = center, top = top, abs_bottom = abs_bottom, abs_top = abs_top, contrast = contrast, load = load, rb = rb, gb = gb, bb = bb
compile_opt idl2

is_abs_bottom = n_elements(abs_bottom) ne 0
is_abs_top = n_elements(abs_top) ne 0
if n_elements(step_colors) gt 0 then begin
    bgr = bytarr(3, 256)
    sz = size(step_colors)
    ncol = isa(step_colors, /number) ? sz[2] : sz[1]
    if is_abs_bottom then ncol++
    if is_abs_top then ncol++
    num_colors = bytarr(3, ncol)
    from = 0
    if is_abs_bottom then begin
        bgr[*, 0] = asu_colortable_create_parse(abs_bottom)
        from = 1
    endif
    up = 0
    if is_abs_bottom then up = 1
    
    for k = from, ncol-1-up do begin
        num_colors[*, k] = asu_colortable_create_parse(step_colors[k-from])
    endfor
    
    step = (255d - from)/(ncol-1-from-up)
    curr_idx = from
    last_k = step/2d
    k = from
    while k lt 256-up do begin
        bgr[*, k] = num_colors[*, curr_idx]
        if k gt last_k then begin
            last_k += step
            curr_idx++
        endif
        k++
    endwhile
    if is_abs_top then begin
        bgr[*, 255] = asu_colortable_create_parse(abs_top)
    endif
    rb = transpose(bgr[2, *])
    gb = transpose(bgr[1, *])
    bb = transpose(bgr[0, *])
endif else begin
    b = dblarr(256)
    g = dblarr(256)
    r = dblarr(256)
    
    default, bottom, 'red'
    default, center, 'white'
    default, top,    'blue'

    bottom = asu_colortable_create_parse(bottom, /normal)
    center = asu_colortable_create_parse(center, /normal)
    top =    asu_colortable_create_parse(top,    /normal)
    default, contrast, 0.8
    default, load,     0

    for k = 0, 127 do begin
        b[k] = bottom[0]  + (center[0]-bottom[0])*k/127d
        g[k] = bottom[1]  + (center[1]-bottom[1])*k/127d
        r[k] = bottom[2]  + (center[2]-bottom[2])*k/127d
        b[255-k] = top[0] + (center[0]-top[0])*k/127d
        g[255-k] = top[1] + (center[1]-top[1])*k/127d
        r[255-k] = top[2] + (center[2]-top[2])*k/127d
    endfor    
    
    contr_scale_t = ((indgen(128)/127d)^contrast)*127d
    contr_scale_inv_t = 255 - contr_scale_t[127:0:-1]
    
    contr_scale = [contr_scale_t, contr_scale_inv_t]
    
    b = interpol(b, contr_scale, indgen(256))
    g = interpol(g, contr_scale, indgen(256))
    r = interpol(r, contr_scale, indgen(256))

    rb = byte(r*255)
    gb = byte(g*255)
    bb = byte(b*255)
    
    if is_abs_bottom then begin
        bott_c = asu_colortable_create_parse(abs_bottom)
        bb[0] = bott_c[0]
        gb[0] = bott_c[1]
        rb[0] = bott_c[2]
    endif
    if is_abs_top then begin
        top_c = asu_colortable_create_parse(abs_top)
        bb[255] = top_c[0]
        gb[255] = top_c[1]
        rb[255] = top_c[2]
    endif
endelse

if load then tvlct, rb, gb, bb

end
