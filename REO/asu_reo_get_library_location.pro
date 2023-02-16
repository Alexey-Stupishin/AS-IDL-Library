function asu_reo_get_library_location

anchor_dirpath = asu_get_anchor_module_dir('gx_box_field_library_version', /funct)
return, anchor_dirpath + '..' + path_sep() + 'binaries' + path_sep() + 'WWNLFFFReconstruction' + asy_get_library_extension()

end
