pro sample_calc_los_tau_plot, hR, hL, valR, valL, title, ytitle, h_harm 

; нарисуем (синяя - левая (в нашем случае необыкновенная), красная - правая (обыкновенная))
pR = plot(hR, valR, '-r3', title = title, xtitle = 'Height, Mm', ytitle = ytitle)
pL = plot(hL, valL, '-b2', overplot = pR)

; добавим маркеры гармоник (пунктирами: 2 - желтый, 3 - зеленый, 4 - голубой)
lim_t = minmax([valR, valL])
p = plot([h_harm[2], h_harm[2]], lim_t, color = 'ORANGE', linestyle = ':', thick = 2, overplot = pR)
p = plot([h_harm[3], h_harm[3]], lim_t, color = 'LIME GREEN', linestyle = ':', thick = 2, overplot = pR)
p = plot([h_harm[4], h_harm[4]], lim_t, color = 'DEEP SKY BLUE', linestyle = ':', thick = 2, overplot = pR)

end
