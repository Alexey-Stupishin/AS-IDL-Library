; IDL Wrapper to:
;   load SDO/HMI data for specified date/time and selected region, 
;   save GX-box models, and
;   external call of Weighted Wiegelmann NLFF Field Reconstruction Method library
;   
; v 2.1.21.1019 (rev.---)
; 
; NB! Beta-version!
; 
; Call:
;   mfo_box_load, obstime, prefix, x_arc, y_arc, dx_km, out_dir, tmp_dir $
;               , aia_uv = aia_uv, aia_euv = aia_euv  
;               , save_pbox = save_pbox, pbox = pbox $
;               , version_info = version_info, NLFFF_filename = NLFFF_filename $
;               , dll_location = dll_location, save_sst = save_sst, _extra = _extra
; 
; Parameters description:
; 
; Parameters required (in):
;   (in)      obstime         (string)                      'YYYY-MM-DD HH:MM:SS' time of the observation (e.g. '2015-12-18 09:12:00')
;   (in)      prefix          (string)                                            arbitrary text for better identification of the saved files
;                                                                                 (e.g. number of the AR)
;   (in)      x_arc           (two-elements numeric array)  arcsec                coordinates on x-axe (along longitude, east-to-west)
;   (in)      y_arc           (two-elements numeric array)  arcsec                coordinates on y-axe (along latitude, south-to-north)
;   (in)      dx_km           (numeric)                     km                    step of the resulting picture in the photosphere plane
;   (in)      out_dir         (string)                                            folder to store resulting files (if there is no such folder, 
;                                                                                 it will be created automatically).
;                                                                                 Take care of enough disk space! 
;                                                                                 each output file (see below) is about e.g. 130 MB for FOV 200x200
;   (in)      tmp_dir         (string)                                            folder to store downloaded SDO/HMI *.fits-files, to avoid 
;                                                                                 multiply downloaded without necessity
;                                                                                 (if there is no such folder, it will be created automatically). 
;                                                                                 Take care of enough disk space! (SDO/HMI observation data for
;                                                                                 one time takes abot 400 MB of disk space)
;   
; Parameters optional (in):
;   (in)      save_pbox       (numeric)                     if not omitted and greater-than-zero, save also full-potential field  model GX-box (postfix .POT)                 
;   (in)      save_bnd        (numeric)                     if not omitted and greater-than-zero, save also photosphere+potential field  model GX-box (postfix .BND)                 
;   (in)      pbox            (structure)                   set this keyword to a variable which will contain generated box structure with potential field solution
;                                                           if save_pbox is not omitted and greater-than-zero
;   (in)      aia_uv          (numeric)                     if not omitted and greater-than-zero, load and store AIA ultraviolet images in GX-box                 
;   (in)      aia_euv         (numeric)                     if not omitted and greater-than-zero, load and store AIA extraultraviolet images in GX-box                 
;   
;   (in)      dll_location    (string)                      full path to calling NLFFF reconstruction DLL; if omitted, DLL will be searched in the folder,
;                                                           containing gx_box_prepare_box.pro procedure (typically SSW\packages\gx_simulator\gxbox)
;   (in)      save_sst        (numeric)                     if not omitted and greater-than-zero, forced saving 'sst-plain' file (*)                 
;   (in)      noSelCheck      (numeric)                     ........................................................................                 
;   (in)      askNLFFF        (numeric)                     ........................................................................                 
;   (in)      _extra          (various data types)          additional setting (such as tuning parameters, additional conditions etc.), is not a subject
;                                                           of the current wrapper implementation 
;   
; Parameters optional (out):
;   (out)     version_info    (string)                      if not omitted, returns the version and copyright of NLFFF library
;   (out)     NLFFF_filename  (string)                      if not omitted, returns the full path to NLFFF-plain file for future using in 
;                                                           radiomap/scan calculations
; 
; Output files:
;   BND-box (potential field in the volume, observed field on the photosphere) in GX-box format, filename postfix "BND.sav": stored anyway  
;   NLFFF-box (NLFFF-reconstructed field) in GX-box format, filename postfix ".NAS.sav": stored if NLFFF reconstuction was performed, 
;     depends on save_nlfff_box parameter value
;     
; * Note: files in "plain" format (without IDL objects) can be stored for special purposes, they are not used in conveyor    
;  
; Protocol of execution:
;   1. Just after start cache will be checked; if necessary files are already in cash, continue; otherwise files will be downloaded
;      from SDO server, it will take some time.
;   2. GX-box created will be created and stored in the BND-box file. 
;      Additionally, GX-box with potential model will be stored ("POT.sav"), if was asked
;   3. (interactive!) Selected region will be shown in contour window and user will be asked:
;       'Continue with selected region? (y/n)'
;      If region selection if not OK, answer 'n', program terminated, user can change input parameters and try again. If 'y' answered, continue.
;   4. (interactive!) user will be asked:
;       'Perform NLFFF? (y/n)'
;      If answer is 'n', program terminated without NLFFF reconstruction. 
;      If answer is 'y', NLFFF reconstruction start (it can take some minutes for usual FOV about 200x200, or tens of minutes for large FOV).
;   5. After NLFFF reconstruction NLFFF-box will be stored.    
;   
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2017-2020
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;

pro mfo_box_load, obstime, prefix, x_arc, y_arc, dx_km, out_dir, tmp_dir $
                , dll_location = dll_location $
                , box = box $
                , dx_maxsize = dx_maxsize $
                , size_fov = size_fov $
                , save_pbox = save_pbox $
                , save_sst = save_sst $
                , save_bnd = save_bnd $
                , version_info = version_info, NLFFF_filename = NLFFF_filename $
                , POT_filename = POT_filename, BND_filename = BND_filename $
                , no_sel_check = no_sel_check $
                , ask_NLFFF = ask_NLFFF, no_NLFFF = no_NLFFF, winclose = winclose $
                , hmi_files = hmi_files, hmi_dir = hmi_dir $
                , aia_uv = aia_uv, aia_euv = aia_euv $
                , pict_dir = pict_dir, pict_win = pict_win, sun_graph = sun_graph, ph_graph = ph_graph $
                , x_mag = x_mag, y_mag = y_mag, full_Bz = full_Bz $
                , bmax = bmax $
                , no_title_prefix = no_title_prefix $
                , find_B_region = find_B_region $
                , hmi_prep = hmi_prep $
                , _extra = _extra 
                
; ----- BASE -----
mfo_box_load_base, obstime, prefix, x_arc, y_arc, dx_km, out_dir, tmp_dir $
                , dx_maxsize = dx_maxsize, dx_kmc = dx_kmc, centre = centre $
                , box = box, save_pbox = save_pbox, pbox = pbox $
                , hmi_files = hmi_files, hmi_dir = hmi_dir $
                , aia_uv = aia_uv, aia_euv = aia_euv $
                , magnetogram = magnetogram, full_Bz = full_Bz, hmi_prep = hmi_prep
    
; ----- SHOW SELECTED REGION -----
    windim = [1200, 700]
    
    bb = sqrt(box.bx^2+box.by^2+box.bz^2)
    bmax = max(bb[*,*,0])
    title = anytim(obstime, out_style = 'ECS') + ', [' + asu_compstr(fix(centre[0])) + ', ' + asu_compstr(fix(centre[1])) + '], Bmax = ' + asu_compstr(fix(bmax))
    if n_elements(no_title_prefix) eq 0 || no_title_prefix eq 0 then title += ' <' + prefix +'>'
    pict_win = window(dimensions = windim, WINDOW_TITLE = title)
    ;ph_graph = contour(box.bz[*,*,0], RGB_TABLE = 0, N_LEVELS=10, ASPECT_RATIO=1.0, LAYOUT=[2,1,1], /FILL, TITLE = title, /CURRENT)
    
    sz = size(box.bx)
    x = indgen(sz[1])*box.index.cdelt1
    y = indgen(sz[2])*box.index.cdelt2
    ph_graph = image(box.bz[*,*,0], RGB_TABLE = 0, ASPECT_RATIO=1.0, LAYOUT=[2,1,1], TITLE = title, /CURRENT)
    xax = axis('X', LOCATION=[x[0],y[0]], target = ph_graph)
    xax.tickdir = 1
    yax = axis('Y', LOCATION=[x[0],y[0]], target = ph_graph)
    yax.tickdir = 1
    
    mdata = magnetogram.data
    idxex = where(abs(magnetogram.data) gt 7000, /NULL)
    mdata(idxex) = 0
    size_fov = size(mdata)
    x_mag = (indgen(size_fov[1])-size_fov[1]/2d)*magnetogram.dx + magnetogram.xc
    y_mag = (indgen(size_fov[2])-size_fov[2]/2d)*magnetogram.dy + magnetogram.yc
    ;sun_graph = contour(mdata, x, y, RGB_TABLE = 0, N_LEVELS=10, ASPECT_RATIO=1.0, LAYOUT=[2,1,2], /FILL, /CURRENT)
    
    sun_graph = image(mdata, x_mag, y_mag, RGB_TABLE = 0, ASPECT_RATIO=1.0, LAYOUT=[2,1,2], /CURRENT)
    xax = axis('X', LOCATION=[x_mag[0],y_mag[0]], target = sun_graph)
    xax.tickdir = 1
    yax = axis('Y', LOCATION=[x_mag[0],y_mag[0]], target = sun_graph)
    yax.tickdir = 1
    
    if keyword_set(pict_dir) && pict_dir ne '' then begin
        outfile = pict_dir + path_sep() + asu_str2filename(anytim(obstime, out_style = 'ECS') $
                + '_' + asu_compstr(fix(centre[0])) + '_' + asu_compstr(fix(centre[1]))) + '_' + asu_compstr(fix(bm)) + '.png'
        pict_win.Save, outfile, width = windim[0], height = windim[1], bit_depth = 2
    endif
    if keyword_set(winclose)then begin
        pict_win.Close
        pict_win = !NULL
    endif
      
; ----- ASK IS OK? -----
    if not keyword_set(no_sel_check) then begin
        ans = ''
        read, ans, prompt = 'Continue with selected region? (y/n) '
        if strlowcase(ans) ne 'y' then return
    endif

    if keyword_set(contour_only) then return
    
    sst_post = '_' + strtrim(string(fix(dx_kmc)), 2) + '_sst'

; ----- ADD AIA FOR SST -----
    asu_box_aia_from_box, box, aia
  
; ----- SAVE POT/BND -----
    asu_box_get_coord, box, boxdata
    input_coords = {x:x_arc, y:y_arc}

    if not keyword_set(save_sst) then save_sst = 0
    if not keyword_set(save_bnd) then save_bnd = 0
    if not keyword_set(save_pbox) then save_pbox = 0
    
    POT_filename = ''
    BND_filename = ''
    if save_bnd gt 0 then begin
        bndp = box.id
        if strlen(prefix) gt 0 then bndp = prefix + '_' + bndp
        save, box, file = filepath(bndp+".sav", root_dir = out_dir)
        if save_sst gt 0 then begin
            fileid = bndp+sst_post
            asu_box_create_mfodata, mfodata, box, box, aia, boxdata, fileid, input_coords=input_coords
            BND_filename = filepath(fileid+".sav", root_dir = out_dir)
            save, file = BND_filename, mfodata 
            message, 'Box structure (potential+boundary) saved to ' + BND_filename,/cont
        endif
    endif
    if save_pbox gt 0 then begin
        potp = pbox.id
        if strlen(prefix) gt 0 then potp = prefix + '_' + potp
        save, file = filepath(potp+".sav", root_dir = out_dir), box
        if save_sst gt 0 then begin
            fileid = potp+sst_post
            asu_box_create_mfodata, mfodata, pbox, box, aia, boxdata, fileid, input_coords=input_coords
            POT_filename = filepath(fileid+".sav", root_dir = out_dir)
            save, file = POT_filename, mfodata
        endif 
    endif
  
; ----- NLFFF/ASK -----
    if keyword_set(no_NLFFF) then return
        
    if keyword_set(ask_NLFFF) then begin
        ans = ''
        read, ans, prompt = 'Perform NLFFF? (y/n) '
        if strlowcase(ans) ne 'y' then return
    endif
          
; ----- NLFFF+SAVE -----
    
    NLFFF_filename = ''
    if not keyword_set(dll_location) then begin
        pro2searchDLL = 'gx_box_make_nlfff_wwas_field'
        resolve_routine, pro2searchDLL, /compile_full_file, /either
        dirpath = file_dirname((ROUTINE_INFO(pro2searchDLL, /source, /functions)).path, /mark)
        dll_location = dirpath + 'WWNLFFFReconstruction.dll'
    endif
    if not keyword_set(version) then version = 1
      
    message, 'Performing NLFFF extrapolation (can take some minutes, or tens of minutes) ...', /cont
    t0 = systime(/seconds)
      
    version_info = ''
    return_code = gx_box_make_nlfff_wwas_field(dll_location, box, version_info = version_info, _extra = _extra)
      
    message, strcompress(string(systime(/seconds)-t0,format="('NLFFF extraplolation performed in ',g0,' seconds')")), /cont
      
    print, version_info
    nlfp = box.id
    if strlen(prefix) gt 0 then nlfp = prefix + '_' + nlfp
    save, file = filepath(nlfp+".sav", root_dir = out_dir), box
    if save_sst gt 0 then begin
        fileid = nlfp+sst_post
        asu_box_create_mfodata, mfodata, box, box, aia, boxdata, fileid, version_info=version_info, input_coords=input_coords
        NLFFF_filename = filepath(fileid+".sav", root_dir = out_dir)
        save, file = NLFFF_filename, mfodata 
        message, 'Box structure (NLFFF) saved to ' + NLFFF_filename,/cont
    endif
end
