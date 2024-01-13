pro asu_ratios, data, xmargin_pix, ymargin_pix, xmargin_ch, ymargin_ch, newsize ; , ratio = ratio, set = set

n_col = 1;
n_row = 1;
if n_elements(!p.multi) ge 3 then begin
    n_col = !p.multi[1] gt 0 ? !p.multi[1] : 1
    n_row = !p.multi[2] gt 0 ? !p.multi[2] : 1
endif

xsz = fix(double(!d.x_size)/n_col)
ysz = fix(double(!d.y_size)/n_row)

char_size = 1.
if !P.CHARSIZE gt 0 then char_size = !P.CHARSIZE
x_ch_scale = float(!D.X_CH_SIZE)*char_size
y_ch_scale = float(!D.Y_CH_SIZE)*char_size

xwin_pix = [!X.WINDOW[0], !X.WINDOW[1]] * !D.X_VSIZE
ywin_pix = [!Y.WINDOW[0], !Y.WINDOW[1]] * !D.Y_VSIZE

xm_pix = !X.MARGIN * x_ch_scale
ym_pix = !Y.MARGIN * y_ch_scale

xwork_pix = xsz - total(xm_pix)
ywork_pix = ysz - total(ym_pix)

sz = size(data)

asu_get_par_keep_ratio, [xwork_pix, ywork_pix], sz[1:2], newsize, coef, win_range, dat_range

xmargin_pix = intarr(2)
xmargin_pix[0] = win_range[0, 0]
xmargin_pix[1] = xwork_pix - win_range[0, 1] - 1
xmargin_pix += xm_pix
xmargin_ch = xmargin_pix / x_ch_scale
ymargin_pix = intarr(2)
ymargin_pix[0] = win_range[1, 0]
ymargin_pix[1] = ywork_pix - win_range[1, 1] - 1
ymargin_pix += ym_pix
ymargin_ch = ymargin_pix / y_ch_scale

end
