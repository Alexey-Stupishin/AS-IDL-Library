pro reo_plot_harmonics, harm, s, h, t, color 

ss = where(s eq harm, count)
if count gt 0 then begin
    hh = h[ss]
    th = t[ss]
    oplot, hh, th, LINESTYLE = 0, PSYM = 4, SYMSIZE = 1, THICK = 1, COLOR = color
endif

end
