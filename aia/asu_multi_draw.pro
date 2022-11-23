pro asu_multi_draw, first, npict, frames, winsize, wave = wave, start = start, ndigits = ndigits

if n_elements(wave) eq 0 then wave = 171
sunglobe_aia_colors, wave, red, green, blue
cm_aia = bytarr(256, 3)
cm_aia[*, 0] = red 
cm_aia[*, 1] = green 
cm_aia[*, 2] = blue

if n_elements(ndigits) eq 0 then ndigits = 5
ndstr = strcompress(string(ndigits),/remove_all)
mask = '[0-9]{' + ndstr + '}'
expr = stregex(first, '(.+)(' + mask + ')\.(.+)',/subexpr,/extract)
if expr[3] eq '' then message, 'Cannot find such files!' 

N = fix(expr[2])
format = '(I0' + ndstr + ')'

t0 = 0
if n_elements(start) ne 0 then t0 = anytim(start)

win = window(dimensions = winsize)

cx = 0
cy = 0
for i = 0, npict-1 do begin
    fname = expr[1] + string(N, format = format) + '.' + expr[3]
    if ~file_test(fname, /READ) then break
    if expr[3] eq 'png' then begin
        data = read_png(fname)
    endif else begin
        data = read_jpeg2000(fname)
    endelse
    title = ''
    margin = [0, 0, 0, 0]
    if n_elements(start) ne 0 then begin 
        title = anytim(t0, /ATIME)
        pos = strpos(title, '.')
        if pos ne -1 then title = strmid(title, 0, pos)
        margin = [0, 0, 0, 0.1]
    endif
    dimage = image(data, RGB_TABLE = cm_aia, LAYOUT=[frames[0], frames[1], i+1], margin = margin, /CURRENT, title = title, FONT_SIZE = 12)
    
    cx++
    if cx ge frames[0] then begin
        cx = 0
        cy++
    endif
    N++    
    t0 += 12
end

end
