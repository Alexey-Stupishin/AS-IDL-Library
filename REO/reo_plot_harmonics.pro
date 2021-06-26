pro reo_plot_harmonics, harm, s, h, t, over, color 

ss = where(s eq harm, count)
if count gt 0 then begin
    hh = h[ss]
    th = t[ss]
    pLh = plot(hh, th, LINESTYLE='', SYMBOL = 'D', SYM_SIZE = 1, SYM_THICK = 1, SYM_COLOR = color, overplot = over)
endif

end
