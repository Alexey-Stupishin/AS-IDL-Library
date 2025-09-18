pro sample_calc_los_tau_plot, hR, hL, valR, valL, title, ytitle, style, h_harm, zero = zero, windim = windim, save_to = save_to

if style eq 0 then begin
    line = '-'
    symbol = 'None'
endif else begin
    line = ''
    symbol = 'o'
endelse

if n_elements(windim) eq 0 then windim = [1500, 1000]

win = window(dimensions = windim)

; нарисуем (синяя - левая (в нашем случае необыкновенная), красная - правая (обыкновенная))
pR = plot(hR, valR, color = 'RED', linestyle = line, thick = 3, name = 'Right' $
        , symbol = symbol, sym_filled = 1, sym_size = 0.6 $
        , title = title, xtitle = 'Height, Mm', ytitle = ytitle, xrange = [0, max([hR, hL])], /current)
pL = plot(hL, valL, color = 'BLUE', linestyle = line, thick = 2, name = 'Left' $
        , symbol = symbol, sym_filled = 1, sym_size = 0.4 $
        , overplot = pR)

; добавим маркеры гармоник (пунктирами: 2 - желтый, 3 - зеленый, 4 - голубой)
lim_t = minmax([valR, valL])
p2 = plot([h_harm[2], h_harm[2]], lim_t, color = 'ORANGE', linestyle = ':', thick = 2, name = '$2^{nd}$ harmonic', overplot = pR)
p3 = plot([h_harm[3], h_harm[3]], lim_t, color = 'LIME GREEN', linestyle = ':', thick = 2, name = '$3^{rd}$ harmonic', overplot = pR)
p4 = plot([h_harm[4], h_harm[4]], lim_t, color = 'DEEP SKY BLUE', linestyle = ':', thick = 2, name = '$4^{th}$ harmonic', overplot = pR)

if n_elements(zero) ne 0 then begin
    lim_h = minmax([hR, hL])
    p = plot(lim_h, [0, 0], color = 'BLACK', linestyle = ':', thick = 2, overplot = pR)
endif

dummy = legend(target = [pR, pL, p2, p3, p4])

if n_elements(save_to) ne 0 then begin
    win.Save, save_to, width = windim[0], height = windim[1], bit_depth = 2
endif

end
