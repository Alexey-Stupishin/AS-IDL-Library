pro test_reu_qs_get_scan_zirin_1991

win = window(dimensions = [1000, 600])
freqs = [4, 6, 10, 12, 14, 16, 18]

for k = 0, n_elements(freqs)-1 do begin
    reu_qs_get_scan_zirin_1991, freqs(k), 950d, 1d, steps, scan
    hp = plot(steps, scan, yrange = [0, 1000], /current)
endfor

end
