pro jet_aia_full_details_to_csv_event_detail, cand, ind_seq, fnum, firstcol, N

mincard = 20

nf = cand.Count()

tstart = !NULL
tmax = !NULL
tend = !NULL
maxcard = 0
maxasp = 0
xmin = !NULL
xmax = !NULL
sy2 = 0d
ntot = 0L
xbox = !NULL
ybox = !NULL
pstart = !NULL
pend = !NULL
prevx = !NULL
prevy = !NULL
prevf = !NULL
speeds = dblarr(nf)
nspeeds = 0
foreach clust, cand, i do begin
    pos = clust.pos
    if tstart eq !NULL then begin
        tstart = ind_seq[pos].date_obs
        tmax = ind_seq[pos].date_obs
        pstart = pos
    endif
    tend = ind_seq[pos].date_obs
    pend = pos
    xarc = ([min(clust.x), max(clust.x)] - ind_seq[pos].CRPIX1)*ind_seq[pos].CDELT1 + ind_seq[pos].CRVAL1 
    yarc = ([min(clust.y), max(clust.y)] - ind_seq[pos].CRPIX2)*ind_seq[pos].CDELT2 + ind_seq[pos].CRVAL2 
    if xbox eq !NULL then begin
        xbox = xarc
        ybox = yarc
        xmin = min(clust.rotx)
        xmax = max(clust.rotx)
    endif
    xmin = min([xmin, min(clust.rotx)])
    xmax = max([xmax, max(clust.rotx)])
    sy2 += total(clust.roty*clust.roty)
    ntot += n_elements(clust.roty)
    xbox[0] = min([xbox[0], xarc[0]])
    xbox[1] = max([xbox[1], xarc[1]])
    ybox[0] = min([ybox[0], yarc[0]])
    ybox[1] = max([ybox[1], yarc[1]])
    maxcard = max([maxcard, n_elements(clust.x)], imax)
    if imax eq 1 then tmax = ind_seq[pos].date_obs
    if finite(clust.aspect) && n_elements(clust.x) ge mincard then maxasp = max([maxasp, clust.aspect])
    if n_elements(clust.x) gt 0 then begin
        if prevx ne !NULL then begin
            speed = pipeline_aia_irc_get_aspects_clusters_get_speed(prevx, prevy, clust.x, clust.y, i - prevf)
            speeds[nspeeds] = speed
            nspeeds += 1
        endif
        prevx = clust.x
        prevy = clust.y
        prevf = i
    endif
endforeach

maxspeed = 0d
avspeed = 0d
medsp = 0d
if nspeeds gt 0 then begin
    speeds = speeds[0:nspeeds-1]
    maxspeed = max(speeds)
    avspeed = total(speeds)/nspeeds
    medsp = median(speeds)
endif

moving = pipeline_aia_irc_get_aspects_clusters_get_speed(cand[0].x, cand[0].y, cand[nf-1].x, cand[nf-1].y, nf-1)

avw = sqrt(sy2/ntot)
totlng = xmax-xmin
asplng = totlng/avw
wsec = (pend - pstart) * 12;
dmin = wsec/60
dsec = wsec - dmin*60
dur = string(dmin, "'", dsec, '"', FORMAT = '(I, A, I02, A)') 

printf, fnum, firstcol, N, dur, maxcard, clust[0].totasp, maxasp, asplng, moving, maxspeed, avspeed, medsp, totlng, avw $
      , FORMAT = '(%"%s, %d, %s, %d, %5.2f, %5.2f, %5.2f, %6.0f, %6.0f, %6.0f, %6.0f, %6.1f, %6.1f")'

end
