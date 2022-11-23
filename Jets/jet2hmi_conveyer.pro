function jet2hmi_conveyer, id, params, filename, fncsv, outpath, pictpath, confpath $
                         , boxespath = boxespath, cachepath = cachepath

if n_elements(boxespath) eq 0 then boxespath = 'g:\BIGData\UData\SDOBoxes'
if n_elements(cachepath) eq 0 then cachepath = 'g:\BIGData\UCache\HMI'

file_mkdir, outpath
file_mkdir, pictpath
file_mkdir, confpath

jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds
jet2hmi_candidates_info, fncsv, csvinfo

if n_elements(details) eq 0 then message, "No details"

foreach detail, details, i do begin
    jet2hmi_conveyer_detail, id, i, params, csvinfo[i], detail, frames, coords, outpath, pictpath, confpath $
                           , boxespath = boxespath, cachepath = cachepath
endforeach

return, n_elements(details)
    
end
