pro asu_plt_winplot, cnt, title, winsize, color = color, back = back 

if n_elements(back) eq 0 then back = 'FFFFFF'x 
if n_elements(color) eq 0 then color = '000000'x 

window, cnt, title = title, xsize = winsize[0], ysize = winsize[1]
cnt++
device, decompose = 1
!p.background = back
!p.color = color

end
