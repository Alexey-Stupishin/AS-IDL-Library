; AGS Utilities collection
;   RATAN: distance to scan line 
;   
; Call:
;       d = asu_ratan_distance(x, y, position_angle, RSun = RSun, scan_pos = scan_pos)
;       
; Call samples:      
;       d = asu_ratan_distance(465, 230, 23.9, RSun = 955.15, scan_pos = scan_pos)
;       d = asu_ratan_distance(465, 230, asu_ratan_position_angle(0, 1.74, 24.6), RSun = 955.15, scan_pos = scan_pos)
; 
; Parameters
;   Required:
;       (in)  x - x-coordinate of POI (E-W direction), arcsec
;       (in)  y - y-coordinate of POI (S-N direction), arcsec
;       (in)  position_angle - RATAN position angle, can be obtained by asu_ratan_position_angle call
;       
;   Optional:
;       (in)  RSun - solar radius, arcsec (default 960)    
;       (out) scan_pos - position on scan, arcsec
;       
;   Return value:
;       distance from POI to scan line    
;       
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2021
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;

function asu_ratan_distance, x, y, position_angle, RSun = RSun, scan_pos = scan_pos

if n_elements(RSun) eq 0 then RSun = 960d 

xx = x/RSun
yy = y/RSun

sa = sin(position_angle*!DTOR)
ca = cos(position_angle*!DTOR)

if arg_present(scan_pos) then scan_pos = (xx*ca + yy*sa)*RSun
yrot = -xx*sa + yy*ca

return, yrot*RSun

end
