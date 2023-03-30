; AGS Utilities collection
;   RATAN:
;   
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2021
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;

function asu_ratan_scan_position, x, y, t_xy, azimuth, t_get = t_get $
       , scan_dist = scan_dist, position_angle = position_angle, latitude = latitude, longitude = longitude, x_new = x_new, y_new = y_new

if n_elements(t_get) eq 0 then t_get = t_xy

x_new = x
y_new = y
t0 = anytim(t_xy)
jd0 = asu_anytim2julday(t0)
asu_solar_par, jd0, solar_p = solar_p, solar_b = solar_b, solar_r = solar_r, sol_dec = sol_dec
asu_get_hpc_latlon, x/solar_r, y/solar_r, latitude, longitude
position_angle = asu_ratan_position_angle(azimuth, sol_dec, solar_p)

t = anytim(t_get)
if t ne t0 then begin 
    rc = asu_sun_diff_rotation(x, y, t-t0, solar_b, solar_r, x_new, y_new, latitude = latitude, longitude = longitude)
endif        

scan_dist = asu_ratan_distance(x_new, y_new, position_angle, solar_r = solar_r, scan_pos = scan_pos)

return, scan_pos

end
