function asu_get_anchor_module_dir, mod_name, funct = funct

CATCH, err_status
if err_status ne 0 then begin
    message, 'Error anchor procedure/function resolve, check type and existing of procedure/function.', /info
    CATCH, /CANCEL
    return, ''
endif

resolve_routine, mod_name, /compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO(mod_name, /source, function = funct)).path, /mark)

return, dirpath

end
