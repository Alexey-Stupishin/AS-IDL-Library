pro asu_plt_wincont, cnt, title, winsize, loadct = loadct, back = back

if n_elements(loadct) eq 0 then loadct = 0 
if n_elements(back) eq 0 then back = 0 

window, cnt, title = title, xsize = winsize[0], ysize = winsize[1]
cnt++
device, decompose = 0
!p.background = back
loadct, loadct

end
