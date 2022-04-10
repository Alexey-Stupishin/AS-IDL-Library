;-----------------------------------------------------------------
pro mapme_widget_update_controls
compile_opt idl2

mapme_widget_magfield
mapme_widget_atmosphere
mapme_widget_calculate

end

;-------------------------------------------------------------------------
pro mapme_widget_event, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

if (tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST') then begin
    widget_control, event.top, /destroy
    return
endif

if TAG_NAMES(event, /STRUCTURE_NAME) eq  'WIDGET_TIMER' then begin
    eventval = 'TIMER'
endif else begin
    WIDGET_CONTROL, event.id, GET_UVALUE = eventval
endelse         

end

;-----------------------------------------------------------------
pro MapMe_widget_switch_view, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

;WIDGET_CONTROL, event.id, GET_UNAME = eventval
;info = asw_getctrl('TAB_ATMO')

event_name = tag_names(event, /structure_name)

if event_name eq 'WIDGET_TAB' then begin
    tab_id = global['tabs_id', event.tab]
    
    if tab_id eq 'TAB_MAGFIELD' then begin ; Mag. Field
        asw_control, 'LEGMASK', GET_VALUE = drawID
        WSET, drawID
        device, decomposed = 0
        loadct, pref['colortab'], /silent
        tv, global['sample_mask_2']
        mapme_widget_magfield
    endif
        
    if tab_id eq 'TAB_ATMO' then begin ; atmo
        if local['byte_mask_c'] ne !NULL then begin
            asw_control, 'MASK2', GET_VALUE = drawID
            WSET, drawID
            device, decomposed = 0
            loadct, pref['colortab'], /silent
            tv, local['byte_mask_c']
        endif
        
        asw_control, 'SMASK', GET_VALUE = drawID
        WSET, drawID
        device, decomposed = 0
        loadct, pref['colortab'], /silent
        tv, global['sample_mask']
        mapme_widget_atmosphere
    endif
    
    if tab_id eq 'TAB_CALC' then begin
        mapme_widget_calculate
    endif
endif

end

;-----------------------------------------------------------------
pro MapMe_widget
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_LOCAL, local
common G_REO_WIDGET_PREF, pref
common G_ASW_WIDGET, asw_widget

resolve_routine,'mapme_widget_magfield',/compile_full_file, /either
resolve_routine,'mapme_widget_atmosphere',/compile_full_file, /either
resolve_routine,'mapme_widget_calculate',/compile_full_file, /either

global = hash()
local = hash()
pref = hash()
asw_widget = hash()

winsize = [500, 500]
global['winsize'] = winsize
winsize_c = [320, 320]
global['winsize_c'] = winsize_c
winsize_td = [550, 210]
global['winsize_td'] = winsize_td

global['atm_model'] = hash()

global['nt'] = hash()
for k = 1, 7 do begin
    global['nt', k] = 1e16
end

H = [1d-8, 2.5d, 2.7d, 50d]
temp = [4d3, 4d3, 2e6, 2e6]
s = mapme_widget_proceed_value(H, temp, 1, 'temp')
dens = s.dens
atm0 = {H:H, temp:temp, dens:dens, used:1}
global['atm_model', 1] = atm0
atm0.used = 0
for k = 2, 7 do begin
    global['atm_model', k] = atm0
end

global['proj_name'] = ''
global['magfile'] = ''

pref['h_range_defl'] = [0.1, 100]
pref['temp_range_defl'] = [1e3, 1e7]
pref['dens_range_defl'] = [1e9, 1e13]

global['gxbox'] = !NULL

global['h_range'] = pref['h_range_defl']
global['h_scale'] = 'log'
global['temp_range'] = pref['temp_range_defl']
global['temp_scale'] = 'log'
global['dens_range'] = pref['dens_range_defl']
global['dens_scale'] = 'log'
global['pres_range'] = [1e14, 1e17]
global['dens_scale'] = 'log'
global['xmargin'] = [4, 1]
global['ymargin'] = [2, 1]

global['curr_height'] = 0

global['edit_pt'] = !NULL
global['drag_info'] = !NULL

local['byte_bz'] = !NULL
local['b_mask'] = !NULL
local['byte_mask'] = !NULL
local['byte_mask_c'] = !NULL
local['byte_cont'] = !NULL
local['FluxR'] = !NULL
local['FluxL'] = !NULL
local['ScanR'] = !NULL
local['ScanL'] = !NULL

pref['colortab'] = 13

pref['path'] = ''
pref['proj_path'] = ''
pref['proj_file'] = ''
pref['export_path'] = ''
pref['expsav_path'] = ''
pref['pref_path'] = ''
dirpath = file_dirname((ROUTINE_INFO('MapMe_widget', /source)).path, /mark)
if n_elements(dirpath) gt 0 then begin
    pref['pref_path'] = dirpath + 'mapme.pref'
    if file_test(pref['pref_path']) then begin
        restore, pref['pref_path']
    endif else begin
        save, filename = pref['pref_path'], pref
    endelse    
endif
    
mapme_widget_col_table

base = WIDGET_BASE(TITLE = 'MapMe - Radioemission Calculation Tool', UNAME = 'MAPME', /column, /TLB_KILL_REQUEST_EVENTS)
asw_widget['widbase'] = base
    
    tab_id = 0
    global['tabs_id'] = hash()
    tabs = widget_tab(base, event_pro = 'mapme_widget_switch_view', UVALUE = 'TABS', UNAME = 'TABS')
        currtab = 'SDOHMI'
        sdo = widget_base(tabs,/column, title = 'SDO/HMI', UVALUE = currtab, UNAME = currtab)
            global['tabs_id', tab_id] = currtab
            tab_id++
            boxdir = WIDGET_BASE(sdo, /row)
                dummy = WIDGET_LABEL(boxdir, VALUE = 'Box folder:', XSIZE = 80)
                dt = WIDGET_TEXT(boxdir, UNAME = 'BOXDIR', VALUE = '', XSIZE = 80, YSIZE = 1, /FRAME) ;, /EDITABLE)
                boxbutton = WIDGET_BUTTON(boxdir, VALUE = '...', UVALUE = 'BOXBUTT', SCR_XSIZE = 30)
                loadbutton = WIDGET_BUTTON(boxdir, VALUE = 'Load ...', UVALUE = 'LOADBUTT', SCR_XSIZE = 60)
                lastbutton = WIDGET_BUTTON(boxdir, VALUE = 'Last', UVALUE = 'LASTBUTT', SCR_XSIZE = 60)
            cachedir = WIDGET_BASE(sdo, /row)
                dummy = WIDGET_LABEL(cachedir, VALUE = 'Cache folder:', XSIZE = 80)
                dt = WIDGET_TEXT(cachedir, UNAME = 'CACHEDIR', VALUE = '', XSIZE = 80, YSIZE = 1, /FRAME) ;, /EDITABLE)
                boxbutton = WIDGET_BUTTON(cachedir, VALUE = '...', UVALUE = 'CACHEBUTT', SCR_XSIZE = 30)
                savebutton = WIDGET_BUTTON(cachedir, VALUE = 'Save', UVALUE = 'SAVEBUTT', SCR_XSIZE = 60)
                saveasbutton = WIDGET_BUTTON(cachedir, VALUE = 'Save As ...', UVALUE = 'SAVEASBUTT', SCR_XSIZE = 60)
            parrow = WIDGET_BASE(sdo, /row)
                col1 = WIDGET_BASE(parrow, /column)
                    dtrow = WIDGET_BASE(col1, /row)
                        dummy = WIDGET_LABEL(dtrow, VALUE = 'Date/Time:', XSIZE = 120)
                        dt = WIDGET_TEXT(dtrow, UNAME = 'DATETIME', VALUE = '', XSIZE = 12, YSIZE = 1, /FRAME, /EDITABLE)
                    AR = WIDGET_BASE(col1, /row)
                        dummy = WIDGET_LABEL(AR, VALUE = 'AR:', XSIZE = 120)
                        dt = WIDGET_TEXT(AR, UNAME = 'AR', VALUE = '', XSIZE = 12, YSIZE = 1, /FRAME, /EDITABLE)
                    gstep = WIDGET_BASE(col1, /row)
                        dummy = WIDGET_LABEL(gstep, VALUE = 'Grid step, km:', XSIZE = 120)
                        dt = WIDGET_TEXT(gstep, UNAME = 'GRIDSTEP', VALUE = '', XSIZE = 12, YSIZE = 1, /FRAME, /EDITABLE)
                    procbutton = WIDGET_BUTTON(col1, VALUE = 'Proceed', UVALUE = 'PROCBUTT', SCR_XSIZE = 60)
                col2 = WIDGET_BASE(parrow, /column)
                    Xrow = WIDGET_BASE(col2, /row)
                        dummy = WIDGET_LABEL(Xrow, VALUE = 'X from-to, arcsec:', XSIZE = 120)
                        dt = WIDGET_TEXT(Xrow, UNAME = 'XRANGE', VALUE = '', XSIZE = 12, YSIZE = 1, /FRAME, /EDITABLE)
                    Yrow = WIDGET_BASE(col2, /row)
                        dummy = WIDGET_LABEL(Yrow, VALUE = 'Y from-to, arcsec:', XSIZE = 120)
                        dt = WIDGET_TEXT(Yrow, UNAME = 'YRANGE', VALUE = '', XSIZE = 12, YSIZE = 1, /FRAME, /EDITABLE)
                    storebutton = WIDGET_BUTTON(col2, VALUE = 'Calc/Store', UVALUE = 'CALCBUTT', SCR_XSIZE = 60)
                col3_0 = WIDGET_BASE(parrow, /column)
                    dummy = WIDGET_LABEL(col3_0, VALUE = '     Save:', XSIZE = 50)
                col3 = WIDGET_BASE(parrow, /column)
                    pot_base = WIDGET_BASE(col3, /row, /Nonexclusive, /align_right)
                        pot = WIDGET_BUTTON(pot_base, VALUE = 'Potential', UNAME = 'STOREPOT', UVALUE = 'STOREPOT', XSIZE = 120)
                    bnd_base = WIDGET_BASE(col3, /row, /Nonexclusive, /align_right)
                        bnd = WIDGET_BUTTON(bnd_base, VALUE = 'Boundary', UNAME = 'STOREBND', UVALUE = 'STOREBND', XSIZE = 120)
                    nlfff_base = WIDGET_BASE(col3, /row, /Nonexclusive, /align_right)
                        nlfff = WIDGET_BUTTON(nlfff_base, VALUE = 'NLFFF', UNAME = 'STORENLFFF', UVALUE = 'STORENLFFF', XSIZE = 120)
                    sst_base = WIDGET_BASE(col3, /row, /Nonexclusive, /align_right)
                        sst = WIDGET_BUTTON(sst_base, VALUE = 'sst (MATLAB friendly)', UNAME = 'STORESST', UVALUE = 'STORESST', XSIZE = 120)
                    
;            fromrow = WIDGET_BASE(sdo, /row)
;                dummy = WIDGET_LABEL(fromrow, VALUE = 'SDO/HMI File: ', XSIZE = 80)
;                fromfiletext = WIDGET_TEXT(fromrow, VALUE = '', UNAME = 'SDOFILETEXT', XSIZE = 120, YSIZE = 1, /FRAME)
;                frombutton = WIDGET_BUTTON(fromrow, VALUE = '...', UVALUE = 'SDOFILE', SCR_XSIZE = 30)
            panes = WIDGET_BASE(sdo, /row)
                pane1 = WIDGET_BASE(panes, /column)
                    sdohmi_box = WIDGET_DRAW(pane1, GRAPHICS_LEVEL = 0, UNAME = 'SDOHMIBOX', UVALUE = 'SDOHMIBOX', XSIZE = winsize[0], YSIZE = winsize[1])
;                    ctrlrow = WIDGET_BASE(pane1, /row)
;                        winfitrow = WIDGET_BASE(ctrlrow, /column, /Exclusive)
;                            size1 = WIDGET_BUTTON(winfitrow, VALUE = 'Observation', UNAME = 'OBSWIN', UVALUE = 'OBSWIN', XSIZE = 80)
;                            size2 = WIDGET_BUTTON(winfitrow, VALUE = 'Selection', UNAME = 'SELWIN', UVALUE = 'SELWIN', XSIZE = 80)
;                            WIDGET_CONTROL, size1, SET_BUTTON = 1
;                            global['drawmode'] = 'OBSWIN'
;                        ops1 = WIDGET_BASE(ctrlrow, /column)
;                            NLFFF = WIDGET_BUTTON(ops1, VALUE = 'NLFFF ...', UVALUE = 'NLFFF', XSIZE = 80)
                pane2 = WIDGET_BASE(panes, /column)
                    sdohmi_phot = WIDGET_DRAW(pane2, GRAPHICS_LEVEL = 0, UNAME = 'SDOHMIPHOT', UVALUE = 'SDOHMIPHOT', XSIZE = winsize[0], YSIZE = winsize[1])
;                    show_mask_base = WIDGET_BASE(pane2, /column, /Nonexclusive)
;                        show_mask = WIDGET_BUTTON(show_mask_base, VALUE = 'Show as Mask', UNAME = 'SHOWMASK', UVALUE = 'SHOWMASK', XSIZE = 100)
        
        sz = size(global['sample_mask'])
        szleg = size(global['sample_mask_2'])
        
        currtab = 'TAB_MAGFIELD'
        mag_field = WIDGET_BASE(tabs,/column, title = 'Magnetic Field', UVALUE = currtab, UNAME = currtab)
            global['tabs_id', tab_id] = currtab
            tab_id++
            fromrow = WIDGET_BASE(mag_field, /row)
                dummy = WIDGET_LABEL(fromrow, VALUE = 'MF File: ', XSIZE = 40)
                fromfiletext = WIDGET_TEXT(fromrow, VALUE = '', UNAME = 'MAGFILETEXT', XSIZE = 120, YSIZE = 1, /FRAME)
                frombutton = WIDGET_BUTTON(fromrow, VALUE = '...', UVALUE = 'MAGFILE', event_pro = 'mapme_widget_event_magfile', SCR_XSIZE = 30)
            panes = WIDGET_BASE(mag_field, /row)
                pane1 = WIDGET_BASE(panes, /column)
                    B_row = WIDGET_BASE(pane1, /row)
                        show_B = WIDGET_DRAW(B_row, GRAPHICS_LEVEL = 0, UVALUE = 'FIELD', UNAME = 'FIELD', XSIZE = winsize[0], YSIZE = winsize[1])
                        slide_B = WIDGET_SLIDER(B_row, VALUE = 0, MINIMUM = 0, MAXIMUM = 20, UNAME = 'BSLIDE', UVALUE = 'BSLIDE', /vertical, /suppress_value, event_pro = 'mapme_widget_event_slide')
                    ctrlrow = WIDGET_BASE(pane1, /row)
                        titcol = WIDGET_BASE(ctrlrow, /column)
                            mft_datetime = WIDGET_LABEL(titcol, VALUE = 'Date/Time: ', XSIZE = 60)
                            mft_center = WIDGET_LABEL(titcol, VALUE = 'Center: ', XSIZE = 60)
                            mft_size = WIDGET_LABEL(titcol, VALUE = 'Size (pix): ', XSIZE = 60)
                        infocol = WIDGET_BASE(ctrlrow, /column, XSIZE = 150)
                            mf_datetime = WIDGET_LABEL(infocol, VALUE = '                    ', UNAME = 'MFDATETIME', XSIZE = 150)
                            mf_center = WIDGET_LABEL(infocol, VALUE = '                    ', UNAME = 'MFCENTER', XSIZE = 150)
                            mf_size = WIDGET_LABEL(infocol, VALUE = '                    ', UNAME = 'MFSIZE', XSIZE = 150)
                            
                        stitcol = WIDGET_BASE(ctrlrow, /column)
                            mft_h = WIDGET_LABEL(stitcol, VALUE = 'Height, Mm: ', XSIZE = 70)
                            mft_bz = WIDGET_LABEL(stitcol, VALUE = 'Bz minmax, G: ', XSIZE = 70)
                            mft_ba = WIDGET_LABEL(stitcol, VALUE = '|B| max, G: ', XSIZE = 70)
                        sinfocol = WIDGET_BASE(ctrlrow, /column)
                            mf_h = WIDGET_LABEL(sinfocol, VALUE = '                    ', UNAME = 'HEIGHT_MM', XSIZE = 100)
                            mf_bz = WIDGET_LABEL(sinfocol, VALUE = '                    ', UNAME = 'BZ_RANGE', XSIZE = 100)
                            mf_ba = WIDGET_LABEL(sinfocol, VALUE = '                    ', UNAME = 'BABS_MAX', XSIZE = 100)
                            
                        ctrlcol = WIDGET_BASE(ctrlrow, /column)
                            scale_base = WIDGET_BASE(ctrlcol, /row, /Nonexclusive) ;, /align_right)
                                scale = WIDGET_BUTTON(scale_base, VALUE = 'Ind. Scale', UNAME = 'IND_SCALE', UVALUE = 'IND_SCALE', event_pro = 'mapme_widget_magfield_update_event', XSIZE = 80)
                            B_base = WIDGET_BASE(ctrlcol, /row, /Nonexclusive) ;, /align_right)
                                B_mode = WIDGET_BUTTON(B_base, VALUE = '|B|', UNAME = 'B_MODE', UVALUE = 'B_MODE', event_pro = 'mapme_widget_magfield_update_event', XSIZE = 80)
                    freqrow = WIDGET_BASE(pane1, /row)
                        freqcol = WIDGET_BASE(freqrow, /column, XSIZE = 200)
                            dummy = WIDGET_LABEL(freqcol, VALUE = 'Frequencies:', XSIZE = 200)
                            editf = WIDGET_TEXT(freqcol, UNAME = 'EDIT_FREQ', VALUE = '4, 8, 12, 16', XSIZE = 30, YSIZE = 1, /FRAME, /EDITABLE)
                            appfrow = WIDGET_BASE(freqcol, /row)
                                freq_appl = WIDGET_BUTTON(appfrow, VALUE = 'Apply', UVALUE = 'HARM_APPLY', event_pro = 'mapme_widget_magfield_update_event', SCR_XSIZE = 50)
                        harmcol = WIDGET_BASE(freqrow, /column, /Nonexclusive, event_pro = 'mapme_widget_magfield_update_event')
                            harm2 = WIDGET_BUTTON(harmcol, VALUE = '2nd harmonic', UNAME = 'HARM2', UVALUE = 'HARM2', XSIZE = 110, event_pro = 'mapme_widget_magfield_update_event')
                            harm3 = WIDGET_BUTTON(harmcol, VALUE = '3rd harmonic', UNAME = 'HARM3', UVALUE = 'HARM3', XSIZE = 110, event_pro = 'mapme_widget_magfield_update_event')
                            harm4 = WIDGET_BUTTON(harmcol, VALUE = '4th harmonic', UNAME = 'HARM4', UVALUE = 'HARM4', XSIZE = 110, event_pro = 'mapme_widget_magfield_update_event')
                pane2 = WIDGET_BASE(panes, /column)
                    maskrow = WIDGET_BASE(pane2, /row)
                        show_mask = WIDGET_DRAW(maskrow, GRAPHICS_LEVEL = 0, UVALUE = 'MASK', UNAME = 'MASK', XSIZE = winsize[0], YSIZE = winsize[1])
                    legrow = WIDGET_BASE(pane2, /row)
                        col2 = WIDGET_BASE(legrow, /column)
                            show_mask_base = WIDGET_BASE(col2, /row, /Nonexclusive, /align_right)
                                show_mask = WIDGET_BUTTON(show_mask_base, VALUE = 'Show as Mask', UNAME = 'SHOWMASK', UVALUE = 'SHOWMASK', event_pro = 'mapme_widget_magfield_update_event', XSIZE = 100)
;                           show_mask_base = WIDGET_BASE(pane2, /row, /Nonexclusive, /align_right)
;                               show_mask = WIDGET_BUTTON(show_mask_base, VALUE = 'Show as Mask', UNAME = 'SHOWMASK', UVALUE = 'SHOWMASK', event_pro = 'mapme_widget_event_mask_show', XSIZE = 100)
                        col1 = WIDGET_BASE(legrow, /column)
                            legend_mask = WIDGET_DRAW(col1, GRAPHICS_LEVEL = 0, UVALUE = 'LEGMASK', UNAME = 'LEGMASK', XSIZE = szleg[1], YSIZE = szleg[2])
                        colt = WIDGET_BASE(legrow, /column)
                            txt1 = WIDGET_LABEL(colt, VALUE = 'QS inter-network', XSIZE = 110)
                            txt2 = WIDGET_LABEL(colt, VALUE = 'QS network lane', XSIZE = 110)
                            txt3 = WIDGET_LABEL(colt, VALUE = 'Enhanced network', XSIZE = 110)
                            txt4 = WIDGET_LABEL(colt, VALUE = 'Plage', XSIZE = 110)
                            txt5 = WIDGET_LABEL(colt, VALUE = 'Facula', XSIZE = 110)
                            txt6 = WIDGET_LABEL(colt, VALUE = 'Penumbra', XSIZE = 110)
                            txt7 = WIDGET_LABEL(colt, VALUE = 'Umbra', XSIZE = 110)
    
        currtab = 'TAB_ATMO'
        atmo = widget_base(tabs,/column, title = 'Atmosphere', UVALUE = currtab, UNAME = currtab)
            global['tabs_id', tab_id] = currtab
            tab_id++
            panes = WIDGET_BASE(atmo, /row)
                pane1 = WIDGET_BASE(panes, /column)
                    show_mask = WIDGET_DRAW(pane1, GRAPHICS_LEVEL = 0, UVALUE = 'MASK2', UNAME = 'MASK2', XSIZE = winsize_c[0], YSIZE = winsize_c[1])
                    edit_group = WIDGET_BASE(pane1, /row)
                        mask_colors = WIDGET_BASE(edit_group, /column)
                            dummy = WIDGET_LABEL(mask_colors, VALUE = 'Mask', XSIZE = sz[1])
                            sample_mask = WIDGET_DRAW(mask_colors, GRAPHICS_LEVEL = 0, UVALUE = 'SMASK', UNAME = 'SMASK', XSIZE = sz[1], YSIZE = sz[2])
                        zones_w_title = WIDGET_BASE(edit_group, /column)
                            dummy = WIDGET_LABEL(zones_w_title, VALUE = 'Used', XSIZE = 100)
                            zones = WIDGET_BASE(zones_w_title, /column, /Nonexclusive, event_pro = 'mapme_widget_switch_zone')
                                zone1 = WIDGET_BUTTON(zones, VALUE = 'QS inter-NW/Common', UNAME = 'ZONE1', UVALUE = 'ZONE1', XSIZE = 130)
                                WIDGET_CONTROL, zone1, SET_BUTTON = 1
                                WIDGET_CONTROL, zone1, SENSITIVE = 0
                                zone2 = WIDGET_BUTTON(zones, VALUE = 'QS NW lane', UNAME = 'ZONE2', UVALUE = 'ZONE2', XSIZE = 110)
                                zone3 = WIDGET_BUTTON(zones, VALUE = 'Enhanced NW', UNAME = 'ZONE3', UVALUE = 'ZONE3', XSIZE = 110)
                                zone4 = WIDGET_BUTTON(zones, VALUE = 'Plage', UNAME = 'ZONE4', UVALUE = 'ZONE4', XSIZE = 110)
                                zone5 = WIDGET_BUTTON(zones, VALUE = 'Facula', UNAME = 'ZONE5', UVALUE = 'ZONE5', XSIZE = 110)
                                zone6 = WIDGET_BUTTON(zones, VALUE = 'Penumbra', UNAME = 'ZONE6', UVALUE = 'ZONE6', XSIZE = 110)
                                zone7 = WIDGET_BUTTON(zones, VALUE = 'Umbra', UNAME = 'ZONE7', UVALUE = 'ZONE7', XSIZE = 110)
                        edit_w_title = WIDGET_BASE(edit_group, /column)
                            dummy = WIDGET_LABEL(edit_w_title, VALUE = 'Edit', XSIZE = 50)
                            edit_now = WIDGET_BASE(edit_w_title, /column, /Exclusive, event_pro = 'mapme_widget_active_zone')
                                edit1 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT1', UVALUE = 'EDIT1', XSIZE = 10)
                                edit2 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT2', UVALUE = 'EDIT2', XSIZE = 10)
                                edit3 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT3', UVALUE = 'EDIT3', XSIZE = 10)
                                edit4 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT4', UVALUE = 'EDIT4', XSIZE = 10)
                                edit5 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT5', UVALUE = 'EDIT5', XSIZE = 10)
                                edit6 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT6', UVALUE = 'EDIT6', XSIZE = 10)
                                edit7 = WIDGET_BUTTON(edit_now, VALUE = '', UNAME = 'EDIT7', UVALUE = 'EDIT7', XSIZE = 10)
                                edit0 = WIDGET_BUTTON(edit_now, VALUE = 'Show', UNAME = 'EDIT0', UVALUE = 'EDIT0', XSIZE = 50)
                                WIDGET_CONTROL, edit0, SET_BUTTON = 1
                                global['edit_mode'] = 0
                        nt_w_title = WIDGET_BASE(edit_group, /column)
                            dummy = WIDGET_LABEL(nt_w_title, VALUE = 'NT', XSIZE = 50)
                            nt1 = WIDGET_TEXT(nt_w_title, UNAME = 'NT1', VALUE = string(global['nt', 1], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt2 = WIDGET_TEXT(nt_w_title, UNAME = 'NT2', VALUE = string(global['nt', 2], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt3 = WIDGET_TEXT(nt_w_title, UNAME = 'NT3', VALUE = string(global['nt', 3], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt4 = WIDGET_TEXT(nt_w_title, UNAME = 'NT4', VALUE = string(global['nt', 4], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt5 = WIDGET_TEXT(nt_w_title, UNAME = 'NT5', VALUE = string(global['nt', 5], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt6 = WIDGET_TEXT(nt_w_title, UNAME = 'NT6', VALUE = string(global['nt', 6], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt7 = WIDGET_TEXT(nt_w_title, UNAME = 'NT7', VALUE = string(global['nt', 7], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            nt_appl = WIDGET_BUTTON(nt_w_title, VALUE = 'Apply', UVALUE = 'NT_APPLY', event_pro = 'mapme_widget_nt_apply', SCR_XSIZE = 30)
                                
                pane2 = WIDGET_BASE(panes, /column)
                    row_temp = WIDGET_BASE(pane2, /row)
                        temp = WIDGET_DRAW(row_temp, GRAPHICS_LEVEL = 0, UVALUE = 'TEMP', UNAME = 'TEMP', XSIZE = winsize_td[0], YSIZE = winsize_td[1] $
                            , /BUTTON_EVENTS, event_pro = 'mapme_widget_edit_temp')
                        ctrl_temp = WIDGET_BASE(row_temp, /column)
                            dummy = WIDGET_LABEL(ctrl_temp, VALUE = 'Height range (Mm):', XSIZE = 100, /align_left)
                            row_h_range = WIDGET_BASE(ctrl_temp, /row)
                                fromhr = WIDGET_TEXT(row_h_range, UNAME = 'FROMHR', VALUE = string(global['h_range', 0], format = '(%"%6.2f")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                                tohr = WIDGET_TEXT(row_h_range, UNAME = 'TOHR', VALUE = string(global['h_range', 1], format = '(%"%6.2f")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            row_h_set = WIDGET_BASE(ctrl_temp, /row)
                                hr_appl = WIDGET_BUTTON(row_h_set, VALUE = 'Apply', UVALUE = 'HR_APPLY', event_pro = 'mapme_widget_hr_apply', SCR_XSIZE = 50)
                                hr_defl = WIDGET_BUTTON(row_h_set, VALUE = 'Default', UVALUE = 'HR_DEFL', event_pro = 'mapme_widget_hr_default', SCR_XSIZE = 50)
                            dummy = WIDGET_LABEL(ctrl_temp, VALUE = 'Temp. range (K):', XSIZE = 100, /align_left)
                            row_t_range = WIDGET_BASE(ctrl_temp, /row)
                                fromtr = WIDGET_TEXT(row_t_range, UNAME = 'FROMTR', VALUE = string(global['temp_range', 0], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                                totr = WIDGET_TEXT(row_t_range, UNAME = 'TOTR', VALUE = string(global['temp_range', 1], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            row_t_set = WIDGET_BASE(ctrl_temp, /row)
                                tr_appl = WIDGET_BUTTON(row_t_set, VALUE = 'Apply', UVALUE = 'TR_APPLY', event_pro = 'mapme_widget_tr_apply', SCR_XSIZE = 50)
                                tr_defl = WIDGET_BUTTON(row_t_set, VALUE = 'Default', UVALUE = 'TR_DEFL', event_pro = 'mapme_widget_tr_default', SCR_XSIZE = 50)
                            dummy = WIDGET_LABEL(ctrl_temp, VALUE = 'Selected (Mm, K):', XSIZE = 100, /align_left)
                            row_t_sel = WIDGET_BASE(ctrl_temp, /row)
                                selh = WIDGET_TEXT(row_t_sel, UNAME = 'SELH', VALUE = '', XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                                selt = WIDGET_TEXT(row_t_sel, UNAME = 'SELT', VALUE = '', XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            row_t_appl = WIDGET_BASE(ctrl_temp, /row)
                                sel_t_appl = WIDGET_BUTTON(row_t_appl, VALUE = 'Apply', UVALUE = 'TVAL_APPLY', event_pro = 'mapme_widget_selt_apply', SCR_XSIZE = 50)
                            
                    row_dens = WIDGET_BASE(pane2, /row)
                        dens = WIDGET_DRAW(row_dens, GRAPHICS_LEVEL = 0, UVALUE = 'DENS', UNAME = 'DENS', XSIZE = winsize_td[0], YSIZE = winsize_td[1] $
                            , /BUTTON_EVENTS, event_pro = 'mapme_widget_edit_dens')
                        ctrl_dens = WIDGET_BASE(row_dens, /column)
                            dummy = WIDGET_LABEL(ctrl_dens, VALUE = 'Dens. range (cm^-3):', XSIZE = 120, /align_left)
                            row_d_range = WIDGET_BASE(ctrl_dens, /row)
                                fromdr = WIDGET_TEXT(row_d_range, UNAME = 'FROMDR', VALUE = string(global['dens_range', 0], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                                todr = WIDGET_TEXT(row_d_range, UNAME = 'TODR', VALUE = string(global['dens_range', 1], format = '(%"%9.2e")'), XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            row_d_set = WIDGET_BASE(ctrl_dens, /row)
                                dr_appl = WIDGET_BUTTON(row_d_set, VALUE = 'Apply', UVALUE = 'DR_APPLY', event_pro = 'mapme_widget_dr_apply', SCR_XSIZE = 50)
                                dr_defl = WIDGET_BUTTON(row_d_set, VALUE = 'Default', UVALUE = 'DR_DEFL', event_pro = 'mapme_widget_dr_default', SCR_XSIZE = 50)
                            dummy = WIDGET_LABEL(ctrl_dens, VALUE = 'Selected (Mm, cm^-3):', XSIZE = 120, /align_left)
                            row_d_sel = WIDGET_BASE(ctrl_dens, /row)
                                selhd = WIDGET_TEXT(row_d_sel, UNAME = 'SELHD', VALUE = '', XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                                seld = WIDGET_TEXT(row_d_sel, UNAME = 'SELD', VALUE = '', XSIZE = 10, YSIZE = 1, /FRAME, /EDITABLE)
                            row_d_appl = WIDGET_BASE(ctrl_dens, /row)
                                sel_d_appl = WIDGET_BUTTON(row_d_appl, VALUE = 'Apply', UVALUE = 'DVAL_APPLY', event_pro = 'mapme_widget_seld_apply', SCR_XSIZE = 50)
                    row_pres = WIDGET_BASE(pane2, /row)
                        pres = WIDGET_DRAW(row_pres, GRAPHICS_LEVEL = 0, UVALUE = 'PRES', UNAME = 'PRES', XSIZE = winsize_td[0], YSIZE = winsize_td[1])
        
        currtab = 'TAB_CALC'
        calc_res = widget_base(tabs,/column, title = 'Calculate', UVALUE = currtab, UNAME = currtab)
            global['tabs_id', tab_id] = currtab
            tab_id++
            panes = WIDGET_BASE(calc_res, /row)
                pane1 = WIDGET_BASE(panes, /column)
                    R_row = WIDGET_BASE(pane1, /row)
                        show_R = WIDGET_DRAW(R_row, GRAPHICS_LEVEL = 0, UVALUE = 'RIGHT', UNAME = 'RIGHT', XSIZE = winsize[0], YSIZE = winsize[1])
                        slide_R = WIDGET_SLIDER(R_row, VALUE = 0, MINIMUM = 0, MAXIMUM = 20, UNAME = 'RSLIDE', UVALUE = 'RSLIDE', /vertical, /suppress_value, event_pro = 'mapme_widget_calculate_event_slide')
                    selfr = WIDGET_BASE(pane1, /row)
                        frct = WIDGET_BASE(selfr, /column)
                            selfr2 = WIDGET_BASE(frct, /row)
                                sel_mode = WIDGET_BASE(selfr2, /column, /Exclusive)
                                    fr_range = WIDGET_BUTTON(sel_mode, VALUE = 'Range', UNAME = 'FR_RANGE', UVALUE = 'FR_RANGE', XSIZE = 50)
                                    fr_list = WIDGET_BUTTON(sel_mode, VALUE = 'List', UNAME = 'FR_LIST', UVALUE = 'FR_LIST', XSIZE = 50)
                                    WIDGET_CONTROL, fr_range, SET_BUTTON = 1
                                sel_data = WIDGET_BASE(selfr2, /column)
                                    fr_range_data = WIDGET_TEXT(sel_data, UNAME = 'FR_RANGE_DATA', VALUE = '4, 18, 1', XSIZE = 16, YSIZE = 1, /FRAME, /EDITABLE)
                                    fr_range_list = WIDGET_TEXT(sel_data, UNAME = 'FR_LIST_DATA', VALUE = '', XSIZE = 16, YSIZE = 1, /FRAME, /EDITABLE)
                            improw = WIDGET_BASE(frct, /row)
                                fr_import = WIDGET_BUTTON(improw, VALUE = 'Import...', UVALUE = 'FR_IMPORT', event_pro = 'mapme_widget_calculate_freq_import', SCR_XSIZE = 60)
                        parcol = WIDGET_BASE(selfr, /column)
                            chckcol = WIDGET_BASE(parcol, /column, /Nonexclusive)
                                ff = WIDGET_BUTTON(chckcol, VALUE = 'Free-free', UNAME = 'FREEFREE', UVALUE = 'FREEFREE', XSIZE = 110)
                                qt = WIDGET_BUTTON(chckcol, VALUE = 'Quasi-transversal', UNAME = 'QT', UVALUE = 'QT', XSIZE = 110)
                                WIDGET_CONTROL, ff, SET_BUTTON = 1
                                WIDGET_CONTROL, qt, SET_BUTTON = 1
                            steprow = WIDGET_BASE(parcol, /row)
                                    dummy = WIDGET_LABEL(steprow, VALUE = 'Vis. Step, arcsec:', XSIZE = 120)
                                    editf = WIDGET_TEXT(steprow, UNAME = 'VIS_STEP', VALUE = '1', XSIZE = 8, YSIZE = 1, /FRAME, /EDITABLE)
                            posrow = WIDGET_BASE(parcol, /row)
                                    dummy = WIDGET_LABEL(posrow, VALUE = 'Pos. Angle,  degrees:', XSIZE = 120)
                                    editf = WIDGET_TEXT(posrow, UNAME = 'POS_ANGLE', VALUE = '0', XSIZE = 8, YSIZE = 1, /FRAME, /EDITABLE)
                                 
                    calcrow = WIDGET_BASE(pane1, /row)
                        calculate = WIDGET_BUTTON(calcrow, VALUE = 'Calculate', UVALUE = 'CALCULATE', event_pro = 'mapme_widget_calculate_calc', SCR_XSIZE = 180)
                pane2 = WIDGET_BASE(panes, /column)
                    L_row = WIDGET_BASE(pane2, /row)
                        show_L = WIDGET_DRAW(L_row, GRAPHICS_LEVEL = 0, UVALUE = 'LEFT', UNAME = 'LEFT', XSIZE = winsize[0], YSIZE = winsize[1])

!p.background = 'FFFFFF'x
!p.color = '000000'x

WIDGET_CONTROL, base, /REALIZE
XMANAGER, 'mapme_widget', base, GROUP_LEADER = GROUP, /NO_BLOCK

mapme_widget_update_controls

asw_control, 'LEGMASK', GET_VALUE = drawID
WSET, drawID
device, decomposed = 0
loadct, pref['colortab'], /silent
tv, global['sample_mask_2']

end