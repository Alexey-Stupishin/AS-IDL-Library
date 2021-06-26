pro reu_qs_get_scan_zirin_1991, freq, R, step $ ; in
                              , steps, scan     ; out
; 
; returns Quiet Sun RATAN scan (by Zirin, Baumert, Hurford, ApJ, 1991, 370, 770, 1991ApJ...370..779Z)
;
; Input:
;   freq - frequency [GHz]
;   R - Solar radius [arcsec]
;   step - data step [arcsec]
;
; Output:
;   steps - position of scan points [arcsec]
;   scan - emulated RATAN scan [Jy/arcsec]
;

    reu_qs_get_scan, freq, rtu_qs_zirin_1991(freq), R, step, steps, scan
    
end