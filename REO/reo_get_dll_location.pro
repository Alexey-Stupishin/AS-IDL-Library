function reo_get_dll_location, libname = libname

dirpath = asu_get_anchor_module_dir('reo_init', /funct)
if not keyword_set(libname) then libname = 'agsGeneralRadioEmission.dll'  

dll_location = dirpath + libname
    
return, dll_location
 
end