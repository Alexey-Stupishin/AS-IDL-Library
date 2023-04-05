function asu_gxbox_calc_lines, box, seeds, result, lib_location = lib_location, _extra = _extra

if n_elements(lib_location) eq 0 then begin
    lib_location = asu_get_anchor_module_dir('gx_box_field_library_version', /funct) $
                 + '..' + path_sep() + 'binaries' + path_sep() + 'WWNLFFFReconstruction' + asy_get_library_extension()
 end

nonStored = gx_box_calculate_lines(lib_location, box $
                        , coords = coords, linesPos = linesPos, linesLength = linesLength, nLines = nLines $
                        , inputSeeds = seeds $
                        , maxLength = 1000000 $
                        , _extra = _extra $
                        )
                        
result = {coords:coords, linesPos:linesPos, linesLength:linesLength, nLines:nLines, nonStored:nonStored}

return, nLines                        

end
