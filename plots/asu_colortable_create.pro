function asu_colortable_create_parse, color

if isa(color, /number, /array) then return, color
if ~isa(color, /string) then return, byte([0, 0, 0])

case color of
    'k':  this_col = 'black'
    'w':  this_col = 'white'
    'a':  this_col = 'gray'
    'da': this_col = 'darkgray'
    'r':  this_col = 'red'
    'dr': this_col = 'darkred'
    'g':  this_col = 'green'
    'dg': this_col = 'darkgreen'
    'b':  this_col = 'blue'
    'db': this_col = 'darkblue'
    'c':  this_col = 'cyan'
    'dc': this_col = 'darkcyan'
    'm':  this_col = 'magenta'
    'dm': this_col = 'darkmagenta'
    'y':  this_col = 'yellow'
    'dy': this_col = 'darkyellow'
    'brown':  this_col = 'darkyellow'
    'p':  this_col = 'pink'
    'v':  this_col = 'violet'
    else: this_col = color
endcase

case this_col of
    'black':       c = [   0,    0,    0]
    'white':       c = [   1,    1,    1]
    'gray':        c = [ 0.5,  0.5,  0.5]
    'darkgray':    c = [0.25, 0.25, 0.25]
    'red':         c = [   0,    0,    1]
    'darkred':     c = [   0,    0,  0.5]
    'green':       c = [   0,    1,    0]
    'darkgreen':   c = [   0, 0.65,    0]
    'blue':        c = [   1,    0,    0]
    'darkblue':    c = [ 0.5,    0,    0]
    'cyan':        c = [   1,    1,    0]
    'darkcyan':    c = [ 0.5,  0.5,    0]
    'magenta':     c = [   1,    0,    1]
    'darkmagenta': c = [ 0.5,    0,  0.5]
    'yellow':      c = [   0,    1,    1]
    'darkyellow':  c = [   0,  0.7,  0.7]
    'pink':        c = [0.71,    0,    1]
    'violet':      c = [   1,    0,  0.5]
    else:          c = [   0,    0,    0]
endcase

return, byte(c*255)

end

pro asu_colortable_create, step_colors = step_colors, bottom = bottom, center = center, top = top, abs_bottom = abs_bottom, contrast = contrast, load = load, rb = rb, gb = gb, bb = bb
compile_opt idl2

is_abs_bottom = n_elements(abs_bottom) ne 0
if n_elements(step_colors) gt 0 then begin
    bgr = bytarr(3, 256)
    sz = size(step_colors)
    ncol = isa(step_colors, /number) ? sz[2] : sz[1]
    if is_abs_bottom then ncol++
    num_colors = bytarr(3, ncol)
    from = 0
    if is_abs_bottom then begin
        bgr[*, 0] = asu_colortable_create_parse(abs_bottom)
        from = 1
    endif
    
    for k = from, ncol-1 do begin
        num_colors[*, k] = asu_colortable_create_parse(step_colors[k-from])
    endfor
    
    step = (255d - from)/(ncol-1-from)
    curr_idx = from
    last_k = step/2d
    k = from
    while k lt 256 do begin
        bgr[*, k] = num_colors[*, curr_idx]
        if k gt last_k then begin
            last_k += step
            curr_idx++
        endif
        k++
    endwhile
    rb = transpose(bgr[2, *])
    gb = transpose(bgr[1, *])
    bb = transpose(bgr[0, *])
endif else begin
    b = dblarr(256)
    g = dblarr(256)
    r = dblarr(256)
    
    default, bottom,   [  0,   0,   1]
    default, center,   [  1,   1,   1]
    default, top,      [  1,   0,   0]
    default, contrast, 0.8
    default, load,     0

    dk = 0
    if is_abs_bottom then begin
        bott_c = asu_colortable_create_parse(abs_bottom)
        b[0] = bott_c[0]
        g[0] = bott_c[1]
        r[0] = bott_c[2]
        dk = 1
    endif
    
    for k = 0, 127 do begin
        b[k+dk] = bottom[0]  + (center[0]-bottom[0])*k/127d
        g[k+dk] = bottom[1]  + (center[1]-bottom[1])*k/127d
        r[k+dk] = bottom[2]  + (center[2]-bottom[2])*k/127d
        b[255-k] = top[0] + (center[0]-top[0])*k/127d
        g[255-k] = top[1] + (center[1]-top[1])*k/127d
        r[255-k] = top[2] + (center[2]-top[2])*k/127d
    endfor    
    
    contr_scale = ((indgen(128)/127d)^contrast)*127d
    contr_scale_inv = 255 - contr_scale[127:0:-1]
    
    if is_abs_bottom then begin
        contr_scale = [contr_scale[0], contr_scale[0:-2], contr_scale_inv]
    endif else begin
        contr_scale = [contr_scale, contr_scale_inv]
    endelse
    r = interpol(r, contr_scale, indgen(256))
    g = interpol(g, contr_scale, indgen(256))
    b = interpol(b, contr_scale, indgen(256))

    rb = byte(r*255)
    gb = byte(g*255)
    bb = byte(b*255)
endelse

if load then tvlct, rb, gb, bb

end
