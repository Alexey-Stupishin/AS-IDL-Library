function reo_get_dll_location, libname = libname

dirpath = file_dirname((ROUTINE_INFO('reo_init', /source, /functions)).path, /mark)
if not keyword_set(libname) then libname = 'agsGeneralRadioEmission.dll'  

dll_location = dirpath + libname
    
return, dll_location
 
end