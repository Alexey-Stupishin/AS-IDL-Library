function asu_sun_diff_rotation_speed, latitude
; degrees/day
; latitude in degrees

diffWc0 = 14.35d
diffWc2 = -2.77d
diffWc4 = -0.9856d

sinphi = sin(abs(latitude * !dtor));
s2 = sinphi^2;

return, diffWc0 + s2*(diffWc2 + s2*diffWc4)

end