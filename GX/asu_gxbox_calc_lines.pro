function asu_gxbox_calc_lines, box, seeds, result, dll_location = dll_location

if n_elements(dll_location) eq 0 then begin
    anchor_function = 'gx_box_calculate_lines'
    resolve_routine, anchor_function, /compile_full_file, /either
    dll_location = file_dirname((ROUTINE_INFO(anchor_function, /source, /functions)).path, /mark) + 'WWNLFFFReconstruction.dll'
end

nonStored = gx_box_calculate_lines(dll_location, box $
                        , coords = coords, linesPos = linesPos, linesLength = linesLength, nLines = nLines $
                        , inputSeeds = seeds $
                        , maxLength = 1000000 $
                        )
                        
result = {coords:coords, linesPos:linesPos, linesLength:linesLength, nLines:nLines, nonStored:nonStored}

return, nLines                        

end
