function asu_sun_diff_rotation_speed, latitude, user = user $
       , howard = howard, allen = allen, snodgrass = snodgrass, schroter = schroter, how70 = how70, xset = xset
; degrees/day
; latitude in degrees
compile_opt idl2

mode = 0 ; howard
if keyword_set(allen) then mode = 1
if keyword_set(snodgrass) then mode = 2
if keyword_set(xset) then mode = 3
if keyword_set(schroter) then mode = 4
if keyword_set(how70) then mode = 5
if keyword_set(user) then mode = 6
    
case mode of
    1: set = [14.44d, -3.00d, 0d]
       ;  Allen, Astrophysical Quantities
    2: set = [14.252d, -1.678d, - 2.401d]
       ;  Magnetic features as used by the Solar Orbiter project for planning
       ;  (Snodgrass and Ulrich, 1990, Ap. J., 351, 309-316)
    3: set = [14.35d, -2.77d, -0.9856d]
       ;  unidentified source
    4: set = [14.5d, -5.61d, 0d]
       ; Ca+
       ; (Schrotr, Wohl, 1975, Solar Physics, 42, 35) 
    5: set = [13.76d, -1.74d, 2.19d]
       ; magnetograms, Mt.Wilson
       ; (Howard, Harvey, 1970, Solar Physics, 12, 23)
    6: set = user
       ;  user settings
    else: set = [14.326d, -2.119d, -1.836d]
       ;  Small magnetic features 
       ;  (Howard, Harvey, and Forgach, 1990, Solar Physics, 130, 295)
endcase

sinphi = sin(abs(latitude * !dtor));
s2 = sinphi^2;

return, set[0] + s2*(set[1] + s2*set[2])

end