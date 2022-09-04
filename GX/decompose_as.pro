function decompose_as, mag, cont, used
;uses CLOSEST function
;mag and cont are 2D image arrays

;cutoff_qs=get_cont_qs(mag, cont)
mag_qs=10  ;10 Gauss for QS
thr_plage=3 ;MF in plage is thr_plage times stronger than QS

absmag=abs(mag)

nonusedidx = where(used eq 0)
magtest = absmag
magtest(nonusedidx) = mag_qs + 1
sub=where(magtest lt mag_qs, count)
cutoff_qs=total(cont[sub])/count
print, cutoff_qs, count

;exclude sunspots
usedidx = where(used ne 0)
conttest = cont(usedidx)
sub=where(conttest gt cutoff_qs*0.9,count)
pdf = HISTOGRAM(conttest(sub), nbins=n_elements(conttest), LOCATIONS=xbin)
cdf = TOTAL(pdf, /CUMULATIVE) / count
cutoff_b=xbin[CLOSEST(cdf,0.75)]
cutoff_f=xbin[CLOSEST(cdf,0.97)]
print, cutoff_b, cutoff_f

;creating decomposition mask
s=size(cont)
model_mask=intarr(s(1),s(2))
model_mask(*,*)=0

;umbra
sub=where(cont le 0.65*cutoff_qs and used, n_umbra)
print, 'umbra: nelem= ',n_umbra,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
model_mask(sub)=7

;penumbra
sub=where(cont gt 0.65*cutoff_qs and cont le 0.9*cutoff_qs and used, n_penumbra)
print, 'penumbra: nelem= ',n_penumbra,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
model_mask(sub)=6

;enhanced NW
sub=where(cont gt cutoff_f and cont le 1.19*cutoff_qs and used, n_enw)
if n_enw ne 0 then begin 
    model_mask(sub)=3
    print, 'eNW: nelem= ',n_enw,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
end

;NW lane
sub=where(cont gt cutoff_b and cont le cutoff_f and used, n_nw)
if n_nw ne 0 then begin 
    model_mask(sub)=2
    print, 'NW: nelem= ',n_nw,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
end

;IN
sub=where(cont gt 0.9*cutoff_qs and cont le cutoff_b and used, n_in)
if n_in ne 0 then begin 
    model_mask(sub)=1
    print, 'IN: nelem= ',n_in,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
end

;plage
sub=where(cont gt 0.95*cutoff_qs and cont le cutoff_f and abs(mag) gt thr_plage*mag_qs and used, n_plage)
if n_plage ne 0 then begin
    model_mask(sub)=4
    print, 'plage: nelem= ',n_plage,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
end

;facula
sub=where(cont gt 1.01*cutoff_qs and abs(mag) gt thr_plage*mag_qs and used, n_facula)
if n_facula ne 0 then begin
    model_mask(sub)=5
    print, 'facula: nelem= ',n_facula,' abs(B) range: ',min(absmag(sub)), max(absmag(sub))
end

n_tot=n_in+n_nw+n_enw+n_plage+n_facula+n_penumbra+n_umbra
print, n_tot
print, n_elements(cont)

model_mask(nonusedidx) = 0

return,model_mask
end