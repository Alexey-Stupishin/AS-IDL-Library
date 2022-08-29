function asu_gxbox_get_line, line_res, index, boxdata, rotator = rotator

line = line_res.coords[0:2, line_res.linesPos[index]:(line_res.linesPos[index]+line_res.linesLength[index]-1)]

if n_elements(rotator) eq 0 then begin
    line[0, *] *= boxdata.dx*boxdata.rsun
    line[1, *] *= boxdata.dy*boxdata.rsun
    line[2, *] *= boxdata.dx*boxdata.rsun
endif else begin
    line = asu_gxbox_rotate_line(line, rotator)
endelse    


return, line

end
