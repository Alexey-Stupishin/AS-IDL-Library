pro asu_plt_winplot, cnt, title, winsize, color = color, back = back, thick = thick

if n_elements(back) eq 0 then back = 'FFFFFF'x 
if n_elements(color) eq 0 then color = '000000'x 
if n_elements(thick) eq 0 then thick = 2 

window, cnt, title = title, xsize = winsize[0], ysize = winsize[1]
cnt++
device, decompose = 1
!p.background = back
!p.color = color
!p.thick = thick

end
