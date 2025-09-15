pro sample_calc_los_tau_plot, hR, hL, valR, valL, title, ytitle, style, h_harm, zero = zero

if style eq 0 then begin
    line = '-'
    symbol = 'None'
endif else begin
    line = ''
    symbol = 'o'
endelse

; нарисуем (синяя - левая (в нашем случае необыкновенная), красная - правая (обыкновенная))
pR = plot(hR, valR, color = 'RED', linestyle = line, thick = 3 $
        , symbol = symbol, sym_filled = 1, sym_size = 0.6 $
        , title = title, xtitle = 'Height, Mm', ytitle = ytitle, xrange = [0, max([hR, hL])])
pL = plot(hL, valL, color = 'BLUE', linestyle = line, thick = 2 $
        , symbol = symbol, sym_filled = 1, sym_size = 0.4 $
        , overplot = pR)

; добавим маркеры гармоник (пунктирами: 2 - желтый, 3 - зеленый, 4 - голубой)
lim_t = minmax([valR, valL])
p = plot([h_harm[2], h_harm[2]], lim_t, color = 'ORANGE', linestyle = ':', thick = 2, overplot = pR)
p = plot([h_harm[3], h_harm[3]], lim_t, color = 'LIME GREEN', linestyle = ':', thick = 2, overplot = pR)
p = plot([h_harm[4], h_harm[4]], lim_t, color = 'DEEP SKY BLUE', linestyle = ':', thick = 2, overplot = pR)

if n_elements(zero) ne 0 then begin
    lim_h = minmax([hR, hL])
    p = plot(lim_h, [0, 0], color = 'BLACK', linestyle = ':', thick = 2, overplot = pR)
endif

end
