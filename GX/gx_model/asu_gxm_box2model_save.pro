pro asu_gxm_box2model_save, box, out_dir, prefix, tr_height_km = tr_height_km, reduce_passed = reduce_passed, lib_path = lib_path $
                          , no_chr = no_chr, do_gxm = do_gxm

    default, no_chr, 0
    default, do_gxm, 0
    
    if no_chr && ~do_gxm then return
     
    box = asu_gxm_box2model(box, tr_height_km = tr_height_km, reduce_passed = reduce_passed, lib_path = lib_path)
    
    filename = box.id
    if strlen(prefix) gt 0 then filename = prefix + '_' + filename
    
    if ~no_chr then begin
        save, box, file = filepath(filename + ".sav", root_dir = out_dir)
    endif
        
    if no_gxm then begin
        model = gx_importmodel(box)
        save, model, file = filepath(filename + ".gxm", root_dir = out_dir)
    endif
    
end
