function asm_twosinc, t, k_app

cm = k_app
sm = sqrt(1-k_app^2)
z = 2*acos(k_app)
cay = cos(t)
say = sin(t)

tz = t/z
return, (2*tz*cm*say - sm*cay)/(4*tz^2 - 1)

end
