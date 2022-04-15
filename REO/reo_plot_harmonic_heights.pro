pro reo_plot_harmonic_heights, hB, BB, freq, harm, range, color

Bh = freq/harm/2.799e6
for i = 1, n_elements(hB)-1 do begin
    if (BB[i-1] gt Bh && Bh ge BB[i]) || (BB[i-1] le Bh && Bh lt BB[i]) then begin
        hh = (hB[i] - hB[i-1])/(BB[i] - BB[i-1])*(Bh - BB[i-1]) + hB[i-1]
        oplot, [hh, hh], range, color = color, linestyle = 0, thick = 3
    endif    
endfor    

end
