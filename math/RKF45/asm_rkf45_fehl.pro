function asm_RKF45_fehl, funcname, funcpar, t, h, dir, v, vp, s, ee

rcx = intarr(5)

;vp = call_function(funcname, funcpar, v)

ch = h/4d
vn = v + ch*vp
rcx[4] = call_function(funcname, funcpar, dir, t+ch, vn, p1)

ch = 3d*h/32d
vn = v + ch*(vp + 3d*p1)
rcx[3] = call_function(funcname, funcpar, dir, t+3d*h/8d, vn, p2)

ch = h/2197d
vn = v + ch*(1932d*vp + (7296d*p2 - 7200d*p1))
rcx[1] = call_function(funcname, funcpar, dir, t+12d*h/13d, vn, p3)

ch = h/4104d
vn = v + ch*((8341d*vp - 845d*p3) + (29440d*p2 - 32832d*p1))
rcx[0] = call_function(funcname, funcpar, dir, t+h, vn, p4)

ch = h/20520d
vn = v + ch*((-6080d*vp + (9295d*p3 - 5643d*p4)) + (41040d*p1 - 28352d*p2))
rcx[2] = call_function(funcname, funcpar, dir, t+h/2d, vn, p5)

ch = h/7618050d
s = v + ch*((902880d*vp + (3855735d*p3 - 1371249d*p4)) + (3953664d*p2 + 277020d*p5))

ee = abs((-2090d*vp + (21970d*p3 - 15048d*p4)) + (22528d*p2 - 27360d*p5))

return, rcx[0] + ishft(rcx[1],1) + ishft(rcx[2],2) + ishft(rcx[3],3) + ishft(rcx[4],4)

end
