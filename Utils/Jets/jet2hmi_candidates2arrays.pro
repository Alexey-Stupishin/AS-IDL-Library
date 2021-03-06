pro jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds

restore, filename, /RELAXED_STRUCTURE_ASSIGNMENT

details = !NULL
cntdet = found_candidates.Count();
if cntdet eq 0 then return 

cntfrm = 0;
cntcrd = 0;
for i = 0, found_candidates.Count()-1 do begin
    cand = found_candidates[i]
    frames = cand.frames
    for j = 0, frames.Count()-1 do begin
        frame = frames[j]
        cntfrm++
        cntcrd += n_elements(frame.x)
    endfor  
endfor  

details = replicate({N:0L, FramePtr:0L, NFrames:0L, MaxCard:0L, MaxCardFrame:0L $
                   , TotAsp:0d, MaxAsp:0d, maxBasp:0d}, cntdet)
frames  = replicate({Card:0L, CoordPtr:0L, Aspect:0d, BAspect:0d, FitsN:0L, Beta:0d $
                   , cdelt1:0d, cdelt2:0d, crpix1:0d, crpix2:0d, crval1:0d, crval2:0d $
                   , time_obs:'', wave:0}, cntfrm)
coords  = lonarr(2, cntcrd)
rotcrds = lonarr(2, cntcrd)

framePtr = 0
coordPtr = 0
for i = 0, found_candidates.Count()-1 do begin
    cand = found_candidates[i]
    cframes = cand.frames
    details[i].N = i + 1
    details[i].FramePtr = framePtr
    details[i].NFrames = cframes.Count()
    details[i].TotAsp = cand[0].total_asp
    maxasp = 0d
    maxbasp = 0d
    for j = 0, cframes.Count()-1 do begin
        frame = cframes[j]
        f = framePtr + j
        p = frame.pos
        card = n_elements(frame.x)
        frames[f].Card = card
        if details[i].MaxCard lt card then begin
            details[i].MaxCard = card
            details[i].MaxCardFrame = f
        endif
        frames[f].Aspect = frame.aspect
        maxasp = max([maxasp, frame.aspect])
        frames[f].Baspect = frame.baspect
        maxbsp = max([maxbasp, frame.baspect])
        frames[f].FitsN = p
        frames[f].beta = frame.beta
        frames[f].CDELT1 = ind_seq[p].CDELT1
        frames[f].CDELT2 = ind_seq[p].CDELT2
        frames[f].CRPIX1 = ind_seq[p].CRPIX1
        frames[f].CRPIX2 = ind_seq[p].CRPIX2
        frames[f].CRVAL1 = ind_seq[p].CRVAL1
        frames[f].CRVAL2 = ind_seq[p].CRVAL2
        frames[f].time_obs = ind_seq[p].T_OBS
        frames[f].wave = ind_seq[p].WAVELNTH
        
        from = coordPtr
        to = coordPtr + card - 1
        coords[0, from:to] = frame.x 
        coords[1, from:to] = frame.y 
        rotcrds[0, from:to] = frame.rotx 
        rotcrds[1, from:to] = frame.roty
        coordPtr = to + 1
         
        frames[f].CoordPtr = from
    endfor  
    details[i].MaxAsp = maxasp
    details[i].MaxBasp = maxbasp
    
    framePtr += details[i].NFrames
endfor  

end
