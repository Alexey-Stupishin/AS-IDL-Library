pro jet2hmi_candidates_store, filename, outfile_base

jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds

foreach detail, details, i do begin
    outfile = outfile_base + '_(' + asu_compstr(i+1) + ').sav'
    save, filename = outfile, detail, frames, coords
endforeach

end