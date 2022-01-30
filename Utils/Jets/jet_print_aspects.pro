pro jet_print_aspects, cands

openw, U, 'c:\temp\aspects2.csv', /get_lun

for k = 0, cands.Count()-1 do begin
    c = cands[k]
    frames = c.frames
    for f = 0, frames.Count()-1 do begin
        frame = frames[f]
        printf, U, k+1, frame.pos, frame.card, frame.beta, frame.aspect, frame.baspect, frame.waspect, frame.speed, FORMAT = '(%"%d,%d,%d,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f")'
    endfor    
endfor

close, U
free_lun, U

end
