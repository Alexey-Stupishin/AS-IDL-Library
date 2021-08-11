function jet2hmi_conveyer, id, filename, fncsv, outfile, outpict $
                         , boxespath = boxespath, cachepath = cachepath

if n_elements(boxespath) eq 0 then boxespath = 'g:\BIGData\UData\SDOBoxes'
if n_elements(cachepath) eq 0 then cachepath = 'g:\BIGData\UCache\HMI'

jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds
jet2hmi_candidates_info, fncsv, info

foreach detail, details, i do begin
    jet2hmi_conveyer_detail, id, i, info[i], detail, frames, coords, outfile, outpict $
                           , boxespath = boxespath, cachepath = cachepath
endforeach

return, n_elements(details)
    
end
