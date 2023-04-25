pro asu_gx_get_scans_by_gx_model, mag_file, maps, xarc, scans = scans, freqs = freqs, freq_set = freq_set $
                                , subtr = subtr, rot = rot, visstep = visstep
compile_opt idl2

restore, mag_file

asu_convert_gx_map_set, map, data, index, freqs = freqs, freq_set = freq_set
if n_elements(rot) ne 0 then begin
    asu_fits_rotate, data, index, rot, maps, out_index
endif else begin
    maps = data
    out_index = index
endelse
if n_elements(subtr) ne 0 then maps -= subtr

visstep = out_index[0].cdelt1
sz = size(data)
xarc = (indgen(sz[1])-(sz[1]-1)/2d)*visstep + out_index[0].xcen
basev = (-(sz[2]-1)/2d)*out_index[0].cdelt2 + out_index[0].ycen
steps = [out_index[0].cdelt1, out_index[0].cdelt2]

if arg_present(scans) then begin
    scans = dblarr(sz[1], sz[3])
    for k = 0, sz[3]-1 do begin
        rtu_create_ratan_diagrams, freq_set[k], sz[1:2], steps, [0, basev], diagrH, diagrV
        scans[*,k] = rtu_map_convolve(maps[*,*,k], diagrH, diagrV, steps)
    endfor  
end

end  
