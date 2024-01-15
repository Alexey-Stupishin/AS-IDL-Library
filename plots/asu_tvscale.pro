pro asu_tvscale, image2show, x_arg, y_arg $
    , xtitle = xtitle, ytitle = ytitle $
    , axis_color_idx = axis_color_idx, bkgr_color_idx = bkgr_color_idx $
    , cm_symm = cm_symm, cm_asymm = cm_asymm, minvalue = minvalue, maxvalue = maxvalue $
    , outimage = img, xout = xout, yout = yout $
    , _extra = _extra

asu_ratios, image2show, xmargin_pix, ymargin_pix, xmargin_ch, ymargin_ch, newsize

if n_elements(cm_symm) gt 0 then begin
    srange = asu_symm_range(image2show)
    minvalue = srange[0]
    maxvalue = srange[1]
endif else begin
    if n_elements(cm_asymm) gt 0 then begin
        srange = asu_asymm_range(image2show)
        minvalue = srange[0]
        maxvalue = srange[1]
    endif
endelse

if n_elements(bkgr_color_idx) eq 0 then !P.BACKGROUND = 0 else !P.BACKGROUND = bkgr_color_idx  
if n_elements(axis_color_idx) eq 0 then axis_color_idx = 255

img = congrid(double(image2show), newsize[0], newsize[1])
img = bytscl(img, min = minvalue, max = maxvalue)

xout = findgen(newsize[0])/(newsize[0]-1)*(x_arg[1] - x_arg[0]) + x_arg[0]
yout = findgen(newsize[1])/(newsize[1]-1)*(y_arg[1] - y_arg[0]) + y_arg[0]
contour, img, xout, yout, xstyle = 5, ystyle = 5, /nodata $
       , xmargin = xmargin_ch, ymargin = ymargin_ch
    
tv, img, !d.x_size*!x.window[0], !d.y_size*!y.window[0]
 
!p.multi[0]++
contour, img, xout, yout, xstyle = 1, ystyle = 1, /nodata $
    , xmargin = xmargin_ch, ymargin = ymargin_ch, xrange = [min(x_arg), max(x_arg)], yrange = [min(y_arg), max(y_arg)] $
    , xtitle = xtitle, ytitle = ytitle $
    , color = axis_color_idx, _extra = _extra

end
