;----------------------------------------------------------------------------------
function ass_slit_widget_in_scope, xy, xycorr = xycorr
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

xycorr = xy

if global['data_list'] eq !NULL then return, 0

sz = size(global['data_list'])
xycorr[0] = 0 > xy[0] < (sz[1]-1)
xycorr[1] = 0 > xy[1] < (sz[2]-1)

return, xycorr[0] eq xy[0] && xycorr[1] eq xy[1]

end

;----------------------------------------------------------------------------------
function ass_slit_widget_convert, xy, mode = mode
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if n_elements(mode) gt 0 && mode eq 'win2dat' then begin
    return, (xy - global['data_shift'])*global['coef']
endif else begin
    return, xy/global['coef'] + global['data_shift']
endelse    
    
end

;----------------------------------------------------------------------------------
pro ass_slit_widget_show, mode = mode
compile_opt idl2

common G_ASS_SLIT_WIDGET, global

if global['data_list'] eq !NULL then return
sz = size(global['data_list'])

if global['xy_rt_dat'] eq !NULL && (n_elements(mode) gt 0 && mode eq 'SELWIN') then mode = 'FITWIN'

winsize = global['winsize']
if global['byte_list'] eq !NULL || (n_elements(mode) gt 0 && (mode eq 'MAKESELECT' || global['drawmode'] ne mode)) then begin
    if n_elements(mode) gt 0 && mode eq 'MAKESELECT' then mode = 'SELWIN'
    global['drawmode'] = mode
    global['byte_info'] = lonarr(sz[3])
    global['byte_list'] = dblarr(winsize[0], winsize[1], sz[3])
    case mode of
        'ACTSIZE': begin
            corn = long((winsize-sz[1:2])/2d)
            global['data_shift'] = corn
            global['coef'] = 1d
            for d = 0, 1 do begin
                if corn[d] ge 0 then begin
                    global['dat_range', d, 0] = 0
                    global['dat_range', d, 1] = sz[d+1]-1
                    global['win_range', d, 0] = corn[d]
                    global['win_range', d, 1] = sz[d+1]-1 + corn[d]
                endif else begin
                    global['dat_range', d, 0] = -corn[d]
                    global['dat_range', d, 1] = winsize[d]-1 - corn[d]
                    global['win_range', d, 0] = 0
                    global['win_range', d, 1] = winsize[d]-1
                endelse    
             endfor   
        end
            
        'FITWIN': begin
            global['coef'] = asu_get_scale_keep_ratio(global['winsize'], [0, 0], sz[1:2]-1, newsize)
            global['data_shift'] = lonarr(2)
            global['newsize'] = newsize
            delta = round((winsize-newsize)/2d)
            for d = 0, 1 do begin
                global['dat_range', d, 0] = 0
                global['dat_range', d, 1] = sz[d+1]-1
                global['win_range', d, 0] = delta[d]
                global['win_range', d, 1] = newsize[d]-1 + delta[d]
            endfor
        end
        
        'SELWIN': begin
            xy_lb_dat = global['xy_lb_dat']
            xy_rt_dat = global['xy_rt_dat']
            global['coef'] = asu_get_scale_keep_ratio(global['winsize'], xy_lb_dat, xy_rt_dat, newsize)
            global['newsize'] = newsize
            global['dat_range', 0, 0] = xy_lb_dat[0]
            global['dat_range', 0, 1] = xy_rt_dat[0]
            global['dat_range', 1, 0] = xy_lb_dat[1]
            global['dat_range', 1, 1] = xy_rt_dat[1]
            delta = round((winsize-newsize)/2d)
            for d = 0, 1 do begin
                global['win_range', d, 0] = delta[d]
                global['win_range', d, 1] = newsize[d]-1 + delta[d]
            endfor
            global['data_shift'] = [global['win_range', 0, 0] - round(xy_lb_dat[0]/global['coef']), global['win_range', 1, 0] - round(xy_lb_dat[1]/global['coef'])]
        end    
    endcase
endif 

p = global['currpos']
if global['byte_info', p] eq 0 then begin
    base = dblarr(winsize[0], winsize[1])
    dat_range = global['dat_range']
    if global['drawmode'] eq 'ACTSIZE' then begin
        res = global['data_list', dat_range[0, 0]:dat_range[0, 1], dat_range[1, 0]:dat_range[1, 1], p]
    endif else begin
        newsize = global['newsize']
        coef = global['coef']
        res = bilinear(global['data_list', dat_range[0, 0]:dat_range[0, 1], dat_range[1, 0]:dat_range[1, 1], p], indgen(newsize[0])*coef, indgen(newsize[1])*coef)
    endelse
    win_range = global['win_range']
    base[win_range[0, 0]:win_range[0, 1], win_range[1, 0]:win_range[1, 1]] = res    
    global['byte_list', *, *, p] = bytscl(base)
    global['byte_info', p] = 1
end

asw_control, 'IMAGE', GET_VALUE = drawID
WSET, drawID
;aia_lct_silent,wave = 171,/load
tv, global['byte_list', *, *, p]

device, decomposed = 1
if global['points'].Count() gt 0 then begin
    loadct, 13, /silent
    for k = 0, global['points'].Count()-1 do begin
        x = (global['points'])[k].x 
        y = (global['points'])[k].y 
        xy = ass_slit_widget_convert([x, y], mode = 'dat2win')
        oplot, [xy[0]], [xy[1]], psym = 2, color = 150
    endfor    
endif

if global['approx'] ne !NULL then begin
    xy = global['approx']
    sz = size(xy)
    for k = 0, sz[2]-1 do begin
        xy[*, k] = ass_slit_widget_convert(xy[*, k], mode = 'dat2win')
    endfor    
    oplot, xy[0, *], xy[1, *]
endif

end

;----------------------------------------------------------------------------------
pro ass_slit_widget_buttons_event, event
compile_opt idl2

common G_ASS_SLIT_WIDGET, global
common G_ASW_WIDGET, asw_widget

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

case eventval of
    'IMAGE' : begin
        if global['data_list'] eq !NULL then return
;        sname = TAG_NAMES(event, /STRUCTURE_NAME)
;        case sname of
;            'WIDGET_DRAW': print, 'Draw, Type=' + string(event.type) + ' Press=' + string(event.press*1L) + ' Release=' + string(event.release*1L) + ' x=' + string(event.x) + ' y=' + string(event.y) $
;                                + ' Clicks=' + string(event.clicks) + ' Mod=' + string(event.modifiers) + ' Key=' + string(event.key)
;        endcase
        if event.type eq 0 and event.modifiers eq 2 then begin
            xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
            if ~ass_slit_widget_in_scope(xy) then return
            WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 1
            global['xr'] = event.x
            global['yr'] = event.y
            global['select'] = 1
            print, string(event.x) + ', ' + string(event.y)
        endif else begin
            case event.type of
                0: begin
                    case event.press of
                        1: begin
                            xy = ass_slit_widget_convert([event.x, event.y], mode = 'win2dat')
                            if ~ass_slit_widget_in_scope(xy) then return
                            global['points'].Add, {x:xy[0], y:xy[1]}
                        end
                        
                        4: begin
                            if global['points'].Count() gt 0 then begin
                                global['points'].Remove
                            endif    
                        end        
                        
                        else: begin
                        end        
                    endcase    
                    ass_slit_widget_show
                end

                1: begin
                    WIDGET_CONTROL, event.id, DRAW_MOTION_EVENTS = 0
                    if global['select'] eq 1 then begin
                        xx = minmax([global['xr'], event.x])
                        yy = minmax([global['yr'], event.y])
                        xy_lb_dat_t = long(ass_slit_widget_convert([xx[0], yy[0]], mode = 'win2dat'))
                        in_scope = ass_slit_widget_in_scope(xy_lb_dat_t, xycorr = xy_lb_dat)
                        xy_rt_dat_t = long(ass_slit_widget_convert([xx[1], yy[1]], mode = 'win2dat'))
                        in_scope = ass_slit_widget_in_scope(xy_rt_dat_t, xycorr = xy_rt_dat)
                        global['xy_lb_dat'] = xy_lb_dat
                        global['xy_rt_dat'] = xy_rt_dat
                        asw_control, 'SELWIN', SET_BUTTON = 1
                        ass_slit_widget_show, mode = 'MAKESELECT'
                    end    
                    global['select'] = 0
                end
                
                else: begin
                end        
            endcase  
        endelse            
        if event.type eq 2 then begin
            ass_slit_widget_show
            device, decomposed = 1
            rcolor = 250
            xr = global['xr']
            yr = global['yr']
            oplot, [xr, xr], [yr, event.y], color = rcolor
            oplot, [event.x, event.x], [yr, event.y], color = rcolor
            oplot, [xr, event.x], [yr, yr], color = rcolor
            oplot, [xr, event.x], [event.y, event.y], color = rcolor
            print, string(xr) + '-' + string(event.x) + ', ' + string(yr) + '-' + string(event.y)
        endif    
    end
        
    'SLIDER' : begin
        if global['data_list'] eq !NULL then return
        
        asw_control, 'SLIDER', GET_VALUE = pos
        global['currpos'] = pos-1
        ass_slit_widget_show
    end
        
    'ACTSIZE' : begin
        ass_slit_widget_show, mode = 'ACTSIZE' 
    end
    'FITWIN' : begin
        ass_slit_widget_show, mode = 'FITWIN'
    end
    'SELWIN' : begin
        ass_slit_widget_show, mode = 'SELWIN'
    end
        
    'PROCEED' : begin
        global['data_list'] = asu_get_file_sequence_data(global['path'], global['fromfile'], global['tofile'], ind = ind, err = err)
        case err of
            1: result = DIALOG_MESSAGE('Please select both first and last files!', title = 'Curve Slit Error', /ERROR)
            2: result = DIALOG_MESSAGE('Not enough files found!', title = 'Curve Slit Error', /ERROR)
            else: begin
                global['currpos'] = 0
                global['byte_list'] = !NULL
                global['slit_list'] = !NULL
                asw_control, 'FITWIN', SET_BUTTON = 1
                ass_slit_widget_show, mode = 'FITWIN'
                sz = size(global['data_list'])
                asw_control, 'SLIDER', SET_SLIDER_MIN = 1
                asw_control, 'SLIDER', SET_SLIDER_MAX = sz[3]
                asw_control, 'SLIDER', SET_VALUE = global['currpos'] + 1
            endelse    
        endcase    
    end

    'FILEFROM' : begin
        asw_control, 'FROMFILETEXT', GET_VALUE = fromID
        file = dialog_pickfile(DEFAULT_EXTENSION = 'fits', DIALOG_PARENT = fromID, FILTER = ['*.fits'], GET_PATH = path, PATH = global['path'])
        if file ne '' then begin
            global['path'] = path
            global['fromfile'] = file_basename(file)
            asw_control, 'FROMFILETEXT', SET_VALUE = global['fromfile']
        endif
    end

    'FILETO' : begin
        asw_control, 'TOFILETEXT', GET_VALUE = toID
        file = dialog_pickfile(DEFAULT_EXTENSION = 'fits', DIALOG_PARENT = toID, FILTER = ['*.fits'], GET_PATH = path, PATH = global['path'])
        if file ne '' then begin
            global['path'] = path
            global['tofile'] = file_basename(file)
            asw_control, 'TOFILETEXT', SET_VALUE = global['tofile']  
        endif
    end

    'ORDER' : begin
        global['fit_order'] = widget_info(asw_getctrl('ORDER'), /DROPLIST_SELECT)
    end

    'FIT' : begin
        if global['points'].Count() lt 9 then return
        
        np = global['points'].Count()
        x = dblarr(np) 
        y = dblarr(np) 
        for k = 0, np-1 do begin
            x[k] = (global['points'])[k].x 
            y[k] = (global['points'])[k].y 
        endfor    
        
        order = global['fit_order'] + 1
        maxdist = asm_bezier_appr(x, y, order, result, iter, simpseed = simpseed)
        
        step = [1, 1]
        halfwidth = 3
        data = asm_bezier_markup(result, x, y, step, halfwidth, maxdist = max([maxdist*1.5d, step[1]]))
        
        sz = size(data.x_grid)
        xy = dblarr(2, sz[2])
        xy[0, *] = data.x_grid[3, *]
        xy[1, *] = data.y_grid[3, *]
        global['approx'] = xy
        
        ass_slit_widget_show
        
        ;save, filename = 'c:\temp\bezier.sav', result, x, y, iter, simpseed, data    
             
        bminx = dblarr(order+1)
        bmaxx = dblarr(order+1)
        bminy = dblarr(order+1)
        bmaxy = dblarr(order+1)
    end

    'CLEAR' : begin
        global['points'] = list()
        global['approx'] = !NULL
        ass_slit_widget_show
    end

    'CLEARAPPR' : begin
        global['approx'] = !NULL
        ass_slit_widget_show
    end

    'SAVE' : begin
;        asw_control, 'FROMFILETEXT', GET_VALUE = fromID
;        file = dialog_pickfile(DEFAULT_EXTENSION = 'fits', DIALOG_PARENT = fromID, FILTER = ['*.fits'], GET_PATH = path, PATH = global['path'])
;        if file ne '' then begin
            
        save, filename = 'c:\temp\slitproj.sav', global
    end

    'LAST' : begin
        restore, 'c:\temp\slitproj.sav'
        asw_control, 'FROMFILETEXT', SET_VALUE = global['fromfile']
        asw_control, 'TOFILETEXT', SET_VALUE = global['tofile']
        asw_control, global['drawmode'], SET_BUTTON = 1
        asw_control, 'ORDER', SET_DROPLIST_SELECT = global['fit_order']
        sz = size(global['data_list'])
        asw_control, 'SLIDER', SET_SLIDER_MIN = 1
        asw_control, 'SLIDER', SET_SLIDER_MAX = sz[3]
        asw_control, 'SLIDER', SET_VALUE = global['currpos'] + 1
        ass_slit_widget_show
    end
endcase
end

;----------------------------------------------------------------------------------
pro ass_slit_widget

common G_ASS_SLIT_WIDGET, global
common G_ASW_WIDGET, asw_widget

asw_widget = hash()
global = hash()
global['data_list'] = !NULL
global['slit_list'] = !NULL
global['byte_list'] = !NULL
global['byte_info'] = !NULL
global['data_ind'] = !NULL
global['dat_range'] = lonarr(2, 2)
global['win_range'] = lonarr(2, 2)
global['xy_lb_dat'] = !NULL
global['xy_rt_dat'] = !NULL
global['points'] = list()
global['fit_order'] = 0
global['approx'] = !NULL
global['fromfile'] = ''
global['tofile'] = ''
global['path'] = ''
global['workpath'] = ''
global['currpos'] = ''
global['select'] = 0
winsize = [800, 800]
global['winsize'] = winsize

global['path'] = 'G:\BIGData\UData\Jets\Devl_20211231\Jets\20100620_110400_20100620_120400_813_-683_500_500\aia_data\171'

base = WIDGET_BASE(TITLE = 'SlitZilla', XSIZE = 1200, /column)
asw_widget['widbase'] = base

filecol = WIDGET_BASE(base, /column)
    fromrow = WIDGET_BASE(filecol, /row)
        fromtext = WIDGET_LABEL(fromrow, VALUE = 'From: ', XSIZE = 40)
        fromfiletext = WIDGET_TEXT(fromrow, UNAME = 'FROMFILETEXT', VALUE = '', XSIZE = 120, YSIZE = 1, /FRAME)
        frombutton = WIDGET_BUTTON(fromrow, VALUE = '...', UVALUE = 'FILEFROM', SCR_XSIZE = 30)
    torow = WIDGET_BASE(filecol, /row)
        totext = WIDGET_LABEL(torow, VALUE = 'To: ', XSIZE = 40)
        tofiletext = WIDGET_TEXT(torow, UNAME = 'TOFILETEXT', VALUE = '', XSIZE = 120, YSIZE = 1, /FRAME)
        frombutton = WIDGET_BUTTON(torow, VALUE = '...', UVALUE = 'FILETO', SCR_XSIZE = 30)

mainrow = WIDGET_BASE(base, /row)
    showimage = WIDGET_DRAW(mainrow, GRAPHICS_LEVEL = 0, UNAME = 'IMAGE', UVALUE = 'IMAGE', XSIZE = winsize[0], YSIZE = winsize[1], /BUTTON_EVENTS)
    ctrlcol = WIDGET_BASE(mainrow, /column)
        procbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Proceed Files', UVALUE = 'PROCEED', XSIZE = 80)
        winfitrow = WIDGET_BASE(ctrlcol, /column, /Exclusive)
            size1 = WIDGET_BUTTON(winfitrow, VALUE = 'Fit to Window', UNAME = 'FITWIN', UVALUE = 'FITWIN', XSIZE = 80)
            size2 = WIDGET_BUTTON(winfitrow, VALUE = 'Actual Size', UNAME = 'ACTSIZE', UVALUE = 'ACTSIZE', XSIZE = 80)
            size3 = WIDGET_BUTTON(winfitrow, VALUE = 'Selection', UNAME = 'SELWIN', UVALUE = 'SELWIN', XSIZE = 80)
            WIDGET_CONTROL, size1, SET_BUTTON = 1
            global['drawmode'] = 'FITWIN'
        orderbutton = WIDGET_DROPLIST(ctrlcol, VALUE = ['Linear', '2nd Order', '3nd Order'], UNAME = 'ORDER', UVALUE = 'ORDER', XSIZE = 80)
        fitbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Fit', UVALUE = 'FIT', XSIZE = 80)
        clearbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Clear', UVALUE = 'CLEAR', XSIZE = 80)
        clearapprbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Clear Appr.', UVALUE = 'CLEARAPPR', XSIZE = 80)
        savebutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Save', UVALUE = 'SAVE', XSIZE = 80)
        lastbutton = WIDGET_BUTTON(ctrlcol, VALUE = 'Last', UVALUE = 'LAST', XSIZE = 80)

sliderrow = WIDGET_BASE(base, /row)
    slider = WIDGET_SLIDER(sliderrow, VALUE = 0, UNAME = 'SLIDER', UVALUE = 'SLIDER', XSIZE = winsize[0])

WIDGET_CONTROL, base, /REALIZE
XMANAGER, 'ass_slit_widget_buttons', base, GROUP_LEADER = GROUP, /NO_BLOCK

WIDGET_CONTROL, showimage, GET_VALUE = drawID
WSET, drawID
base = dblarr(winsize[0], winsize[1])
tvplot, base, indgen(winsize[0]), indgen(winsize[1]), /fit_window, xmargin = [0, 0], ymargin = [0, 0]
;oplot, [0, winsize[0]-1], [0, winsize[1]-1]

end