pro irc_principale_comps, x0, y0, vx, vy, caspect = caspect, vbeta = vbeta, rotx = rotx, roty = roty, waspect = waspect, baspect = baspect, tot_lng = tot_lng, av_width = av_width

vbeta = 0d
rotx = x0
roty = y0
tot_lng = 0d
av_width = 0d
caspect = 1d
waspect = 1d
baspect = 1d

n = n_elements(x0)
if n le 1 then return
;if n_elements(uniq(x0, sort(x0))) eq 1 || n_elements(uniq(y0, sort(y0))) eq 1 then begin
;;    stophere = 1;
;    return
;endif

x = double(x0)
y = double(y0)

x -= mean(x) 
y -= mean(y) 

x2 = x ## transpose(x)
y2 = y ## transpose(y)
xy = x ## transpose(y)

;kyx = xy/x2
;kxy = y2/xy

vbeta = 0.5d * atan(2*xy, (x2-y2))

;if ~finite(vbeta) then begin
;    stophere = 1
;endif

;kb = tan(vbeta)

sb = sin(vbeta)
cb = cos(vbeta)

vx = sqrt(cb^2*x2 + 2*cb*sb*xy + sb^2*y2)/n
vy = sqrt(sb^2*x2 - 2*sb*cb*xy + cb^2*y2)/n

mrot = [  [  cb, sb] $
        , [ -sb, cb] ]
crd = dblarr(n, 2)
crd[*, 0] = x
crd[*, 1] = y
result = mrot ## crd
rotx = result[*, 0]
roty = result[*, 1]
ymm = minmax(roty)
xmm = minmax(rotx)

tot_lng = xmm[1]-xmm[0]
av_width = sqrt(total(roty^2)/n_elements(roty))

if vy lt 1e-10 then begin
    return
endif

caspect = vx/vy
waspect = tot_lng/av_width
baspect = tot_lng/(ymm[1]-ymm[0])

;if arg_present(caspect) then begin
;    caspect = vx gt vy ? vx/vy : vy/vx
;;    if ~finite(caspect) then begin
;;        stophere = 1;
;;    endif
;endif

end
