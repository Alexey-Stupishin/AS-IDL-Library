pro jet_aia_full_details_to_csv_event, filename, fnum, id

; jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds
restore, filename, /RELAXED_STRUCTURE_ASSIGNMENT

cntdet = found_candidates.Count();
if cntdet eq 0 then return 

firstcol = id
foreach cand, found_candidates, i do begin
    jet_aia_full_details_to_csv_event_detail, cand, ind_seq, fnum, firstcol, i+1
    ;firstcol = ''
endforeach

end
