function asu_gxbox_get_library_location

anchor_function = 'gx_box_field_library_version'
resolve_routine, anchor_function, /compile_full_file, /either
return, file_dirname((ROUTINE_INFO(anchor_function, /source, /functions)).path, /mark) + '..' + path_sep() + 'binaries' + path_sep() + 'WWNLFFFReconstruction' + asy_get_library_extension()

end
