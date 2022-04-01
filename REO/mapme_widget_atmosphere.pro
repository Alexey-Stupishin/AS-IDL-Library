;----------------------------------------------------------------------------------
pro mapme_widget_update_atmo
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

atm = global['atm_model']

for k = 1, 7 do begin
    buttname = 'ZONE' + asu_compstr(k)
    asw_control, buttname, SET_BUTTON = atm[k].used
endfor

end

;----------------------------------------------------------------------------------
pro mapme_widget_nt_apply, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

for k = 1, 7 do begin
    asw_control, 'NT'+asu_compstr(k), GET_VALUE = v
    global['nt', k] = double(v)
    atm = global['atm_model', k]
    s = mapme_widget_proceed_value(atm.H, atm.temp, k, 'temp')
    atm.dens = s.dens
    global['atm_model', k] = atm
endfor
    
mapme_widget_atmosphere

end

;----------------------------------------------------------------------------------
pro mapme_widget_hr_apply, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

asw_control, 'FROMHR', GET_VALUE = v1
asw_control, 'TOHR', GET_VALUE = v2
global['h_range'] = double([v1, v2])
mapme_widget_atmosphere

end

;----------------------------------------------------------------------------------
pro mapme_widget_hr_default, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref

global['h_range'] = pref['h_range_defl']

asw_control, 'FROMHR', SET_VALUE = asu_compstr(global['h_range', 0])
asw_control, 'TOHR', SET_VALUE = asu_compstr(global['h_range', 1])
mapme_widget_atmosphere

end

;----------------------------------------------------------------------------------
pro mapme_widget_tr_apply, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

asw_control, 'FROMTR', GET_VALUE = v1
asw_control, 'TOTR', GET_VALUE = v2
global['temp_range'] = double([v1, v2])
mapme_widget_atmosphere

end

;----------------------------------------------------------------------------------
pro mapme_widget_tr_default, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref

global['temp_range'] = pref['temp_range_defl']

asw_control, 'FROMTR', SET_VALUE = asu_compstr(global['temp_range', 0])
asw_control, 'TOTR', SET_VALUE = asu_compstr(global['temp_range', 1])
mapme_widget_atmosphere

end

;----------------------------------------------------------------------------------
pro mapme_widget_selt_apply, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref

if global['edit_pt'] eq !NULL then return

asw_control, 'SELH', GET_VALUE = v1
asw_control, 'SELT', GET_VALUE = v2

atm = global['atm_model', global['edit_pt', 0]]
atm.H[global['edit_pt', 1]] = double(v1)
atm.temp[global['edit_pt', 1]] = double(v2)
s = mapme_widget_proceed_value(atm.H[global['edit_pt', 1]], atm.temp[global['edit_pt', 1]], global['edit_pt', 0], 'temp')
atm.dens[global['edit_pt', 1]] = s.dens
global['atm_model', global['edit_pt', 0]] = atm

mapme_widget_atmosphere

end

;----------------------------------------------------------------------------------
function mapme_widget_td_convert, xy, type, mode = mode 
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

winsize = global['winsize_td']
xmargpix = global['xmargin'] * !d.x_ch_size
ymargpix = global['ymargin'] * !d.y_ch_size
xplotpix = winsize[0] - xmargpix[0] - xmargpix[1] 
yplotpix = winsize[1] - ymargpix[0] - ymargpix[1] 

out = dblarr(2)
part = dblarr(2)
if n_elements(mode) gt 0 && mode eq 'win2dat' then begin
    part[0] = double(xy[0]-xmargpix[0])/double(xplotpix)
    part[1] = double(xy[1]-ymargpix[0])/double(yplotpix)
    if global['h_scale'] eq 'log' then begin
        out[0] = exp(alog(global['h_range', 0]) + part[0]*(alog(global['h_range', 1])-alog(global['h_range', 0]))) 
    endif else begin
        out[0] = global['h_range', 0] + part[0]*(global['h_range', 1] - global['h_range', 0]) 
    endelse
    if global[type+'_scale'] eq 'log' then begin
        out[1] = exp(alog(global[type+'_range', 0]) + part[1]*(alog(global[type+'_range', 1])-alog(global[type+'_range', 0]))) 
    endif else begin
        out[1] = global[type+'_range', 0] + part[1]*(global[type+'_range', 1] - global[type+'_range', 0]) 
    endelse
endif else begin
    if global['h_scale'] eq 'log' then begin
        part[0] = (alog(double(xy[0])) - alog(global['h_range', 0]))/(alog(global['h_range', 1]) - alog(global['h_range', 0]))
    endif else begin
        part[0] = (double(xy[0]) - global['h_range', 0])/(global['h_range', 1] - global['h_range', 0])
    endelse
    if global[type+'_scale'] eq 'log' then begin
        part[1] = (alog(double(xy[1])) - alog(global[type+'_range', 0]))/(alog(global[type+'_range', 1]) - alog(global[type+'_range', 0]))
    endif else begin
        part[1] = (double(xy[1]) - global[type+'_range', 0])/(global[type+'_range', 1] - global[type+'_range', 0])
    endelse
    out[0] = part[0]*double(xplotpix) + xmargpix[0] 
    out[1] = part[1]*double(yplotpix) + ymargpix[0] 
endelse    

return, out

end

;----------------------------------------------------------------------
function mapme_widget_proceed_value, h, v, zone, mode
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

nt = global['nt', zone]
v2 = replicate(nt, n_elements(v))/v

if mode eq 'temp' then begin
    s = {temp:v, dens:v2}
endif else begin
    s = {temp:v2, dens:v}
endelse        

return, s

end

;----------------------------------------------------------------------
function mapme_widget_find_point, xy, type, atmk
compile_opt idl2

names = tag_names(atmk)
idx = where(strlowcase(type) eq strlowcase(names))

for n = 0, n_elements(atmk.H)-1 do begin
    dxy = mapme_widget_td_convert([atmk.H[n], atmk.(idx)[n]], type, mode = 'dat2win')
    if ((dxy[0]-xy[0])^2 + (dxy[1]-xy[1])^2) lt 25 then begin
        return, n
    endif    
endfor
    
return, !NULL
    
end

;----------------------------------------------------------------------
pro mapme_widget_edit_temp, event
compile_opt idl2

mapme_widget_edit_atm, event, 'temp'

end

;----------------------------------------------------------------------
pro mapme_widget_edit_dens, event
compile_opt idl2

mapme_widget_edit_atm, event, 'dens'

end

;----------------------------------------------------------------------
pro mapme_widget_edit_atm, event, mode
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

;sname = TAG_NAMES(event, /STRUCTURE_NAME)
;case sname of
;    'WIDGET_DRAW': print, 'Draw, Type=' + string(event.type) + ' Press=' + string(event.press*1L) + ' Release=' + string(event.release*1L) + ' x=' + string(event.x) + ' y=' + string(event.y) $
;                        + ' Clicks=' + string(event.clicks) + ' Mod=' + string(event.modifiers) + ' Key=' + string(event.key)
;endcase

edit = global['edit_mode']

case event.type of
    0: begin ; click
        if edit eq 0 then begin
            atm = global['atm_model']
            for k = 7, 1, -1 do begin
                if atm[k].used then begin 
                    n = mapme_widget_find_point([event.x, event.y], 'temp', atm[k])
                    if n ne !NULL then begin
                        if global['edit_pt'] ne !NULL && global['edit_pt', 0] eq k && global['edit_pt', 1] eq n then begin
                            global['edit_pt'] = !NULL 
                        endif else begin
                            global['edit_pt'] = [k, n]
                        endelse 
                        mapme_widget_atmosphere
                        return
                    endif    
                endif    
            endfor
            return
        endif
        
        atm = global['atm_model', edit]
        n = mapme_widget_find_point([event.x, event.y], mode, atm)
        data = mapme_widget_td_convert([event.x, event.y], mode, mode = 'win2dat')
        case event.press of ; left mouse
            1: begin
                if n eq !NULL then begin
                    s = mapme_widget_proceed_value(data[0], data[1], edit, mode)
                    hupd = [atm.H, data[0]] 
                    tupd = [atm.temp, s.temp]
                    dupd = [atm.dens, s.dens] 
                    idxs = sort(hupd)
                    atmn = {H:hupd[idxs], temp:tupd[idxs], dens:dupd[idxs], used:atm.used}
                    
                    global['atm_model', edit] = atmn
                    idx = where(atmn.H eq data[0])
                    global['edit_pt'] = [edit, idx]
                endif else begin
                    if global['edit_pt'] ne !NULL && global['edit_pt', 0] eq edit && global['edit_pt', 1] eq n then begin
                        if event.modifiers ne 2 then global['edit_pt'] = !NULL 
                    endif else begin
                        global['edit_pt'] = [edit, n]
                    endelse 
                endelse
                
                if event.modifiers eq 2 && global['edit_pt'] ne !NULL then begin ; start drag
                    WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 1
                    global['drag_info'] = global['edit_pt']
                endif    
                mapme_widget_atmosphere
            end
            
            4: begin
                if n ne !NULL then begin
                    hupd = [atm.H[0:n-1], atm.H[n+1:-1]] 
                    tupd = [atm.temp[0:n-1], atm.temp[n+1:-1]] 
                    dupd = [atm.dens[0:n-1], atm.dens[n+1:-1]] 
                    atmn = {H:hupd, temp:tupd, dens:dupd, used:atm.used}
                    
                    global['atm_model', edit] = atmn
                    if global['edit_pt'] ne !NULL && global['edit_pt', 0] eq edit && global['edit_pt', 1] eq n then begin
                        global['edit_pt'] = !NULL
                    endif
                    mapme_widget_atmosphere
                endif    
            end
    
            else: begin
            end                
        endcase
    end
    
    1: begin ; release
        WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 0
        global['drag_info'] = !NULL
        mapme_widget_atmosphere
    end
    
    2: begin ; drag
        if global['drag_info'] ne !NULL then begin
            info = global['drag_info']
            atm = global['atm_model', info[0]]
            data = mapme_widget_td_convert([event.x, event.y], mode, mode = 'win2dat')
            s = mapme_widget_proceed_value(data[0], data[1], info[0], mode)
            atm.H[info[1]] = data[0]
            atm.temp[info[1]] = s.temp
            atm.dens[info[1]] = s.dens
            global['atm_model', info[0]] = atm
            mapme_widget_atmosphere
        endif
    end
    
    else: begin
    end
endcase

end

;----------------------------------------------------------------------
pro mapme_widget_col_table
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref

loadct, pref['colortab'], /silent

h = 24
w = 30

im = dblarr(w, h*7)
for k = 0, 6 do begin
    im[*, (k*h):((k+1)*h-1)] = double(6-k)/6
endfor

global['sample_mask'] = bytscl(im)

h = 15
im = dblarr(w, h*7)
for k = 0, 6 do begin
    im[*, (k*h):((k+1)*h-1)] = double(6-k)/6
endfor

global['sample_mask_2'] = bytscl(im)

end

;----------------------------------------------------------------------
pro mapme_widget_active_zone, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

if event.select eq 0 then return

WIDGET_CONTROL, event.id, GET_UVALUE = eventval
k = long(strmid(eventval, 4, 1))

if k gt 0 then begin
    asw_control, 'ZONE'+asu_compstr(k), SET_BUTTON = 1
endif

global['edit_mode'] = k
mapme_widget_atmosphere

end

;----------------------------------------------------------------------
pro mapme_widget_switch_zone, event
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global

WIDGET_CONTROL, event.id, GET_UVALUE = eventval
k = long(strmid(eventval, 4, 1))
asu_set_hash, global, 'atm_model', k, 'used', event.select

v = widget_info(asw_getctrl('EDIT'+asu_compstr(k)), /BUTTON_SET)
if v ne 0 then begin
    asw_control, 'EDIT0', SET_BUTTON = 1
    global['edit_mode'] = 0
endif    

mapme_widget_atmosphere

end

;----------------------------------------------------------------------
pro mapme_widget_atmosphere_get_edit, atmk, k, value, thick
compile_opt idl2
end

;----------------------------------------------------------------------
pro mapme_widget_atmosphere_plot, H, par, k, value, thick
compile_opt idl2

color = asu_get_color_curr_table(double(k-1)/6, value = value)
oplot, H, par, color = color, linestyle = 0, thick = thick
oplot, H, par, color = color, psym = 6, symsize = 1

end

;----------------------------------------------------------------------
pro mapme_widget_atmosphere_sel_draw, name
compile_opt idl2

common G_REO_WIDGET_PREF, pref

asw_control, name, GET_VALUE = drawID
WSET, drawID
device, decomposed = 1
loadct, pref['colortab'], /silent

end

;----------------------------------------------------------------------
pro mapme_widget_atmosphere
compile_opt idl2

common G_REO_WIDGET_GLOBAL, global
common G_REO_WIDGET_PREF, pref

edit = global['edit_mode']
value = 1
if edit gt 0 then value = 3

atm = global['atm_model']

atmk = !NULL
if global['edit_pt'] ne !NULL && atm[global['edit_pt', 0]].used then begin
    kn = global['edit_pt']
    atmk = atm[kn[0]]
    
    szs = 1.5
    xu = [-1, -1, 1, 1] * szs
    yu = [-1, 1, 1, -1] * szs
    usersym, xu, yu, /fill, color = asu_get_color_curr_table(double(kn[0]-1)/6, value = 1)
    
    asw_control, 'SELH', SET_VALUE = string(atmk.H[[kn[1]]], format = '(%"%6.2f")')
    asw_control, 'SELT', SET_VALUE = string(atmk.temp[[kn[1]]], format = '(%"%9.2e")')
    asw_control, 'SELHD', SET_VALUE = string(atmk.H[[kn[1]]], format = '(%"%6.2f")')
    asw_control, 'SELD', SET_VALUE = string(atmk.dens[[kn[1]]], format = '(%"%9.2e")')
endif else begin
    asw_control, 'SELH', SET_VALUE = ''
    asw_control, 'SELT', SET_VALUE = ''
    asw_control, 'SELHD', SET_VALUE = ''
    asw_control, 'SELD', SET_VALUE = ''
endelse         

mapme_widget_atmosphere_sel_draw, 'TEMP'
plot, [1, 1], [1, 1], xrange = global['h_range'], yrange = global['temp_range'], /xlog, /ylog, /NODATA, xmargin = global['xmargin'], ymargin = global['ymargin']
for k = 1, 7 do begin
    if atm[k].used then begin
        if edit ne k then begin
            mapme_widget_atmosphere_plot, (atm[k]).H, (atm[k]).temp, k, value, 1
        endif               
    endif
endfor
if edit gt 0 then mapme_widget_atmosphere_plot, atm[edit].H, atm[edit].temp, edit, 1, 3
if atmk ne !NULL then oplot, [atmk.H[[kn[1]]]], [atmk.temp[kn[1]]], psym = 8

mapme_widget_atmosphere_sel_draw, 'DENS'
plot, [1, 1], [1, 1], xrange = global['h_range'], yrange = global['dens_range'], /xlog, /ylog, /NODATA, xmargin = global['xmargin'], ymargin = global['ymargin']
for k = 1, 7 do begin
    if atm[k].used then begin
        if edit ne k then begin
            mapme_widget_atmosphere_plot, atm[k].H, atm[k].dens, k, value, 1
        endif               
    endif
endfor
if edit gt 0 then mapme_widget_atmosphere_plot, atm[edit].H, atm[edit].dens, edit, 1, 3
if atmk ne !NULL then oplot, [atmk.H[[kn[1]]]], [atmk.dens[kn[1]]], psym = 8

mapme_widget_atmosphere_sel_draw, 'PRES'
plot, [1, 1], [1, 1], xrange = global['h_range'], yrange = global['pres_range'], /xlog, /ylog, /NODATA, xmargin = global['xmargin'], ymargin = global['ymargin']
for k = 1, 7 do begin
    if atm[k].used then begin
        if edit ne k then begin
            mapme_widget_atmosphere_plot, atm[k].H, atm[k].dens*atm[k].temp, k, value, 1
        endif               
    endif
endfor
if edit gt 0 then mapme_widget_atmosphere_plot, atm[edit].H, atm[edit].dens*atm[edit].temp, edit, 1, 3
if atmk ne !NULL then oplot, [atmk.H[[kn[1]]]], [atmk.dens[kn[1]]*atmk.temp[kn[1]]], psym = 8

end
