function mfo_box_load_template, mode

if mode eq 0 then begin
    templ =  {VERSION:1.0, DATASTART:0, DELIMITER:',', MISSINGVALUE:-99999999, COMMENTSYMBOL:'' $
            , FIELDCOUNT:7 $
            , FIELDTYPES:[7, 7, 3, 4, 4, 4, 4] $
            , FIELDNAMES:['date', 'time', 'AR', 'xfrom', 'xto', 'yfrom', 'yto'] $
            , FIELDLOCATIONS:[0, 11, 24, 30, 34, 38, 40] $
            , FIELDGROUPS:[0, 1, 2, 3, 4, 5, 6] $
             }
endif else begin
    templ =  {VERSION:1.0, DATASTART:0, DELIMITER:',', MISSINGVALUE:-99999999, COMMENTSYMBOL:'' $
            , FIELDCOUNT:8 $
            , FIELDTYPES:[7, 7, 3, 4, 4, 4, 4, 4] $
            , FIELDNAMES:['date', 'time', 'AR', 'xfrom', 'xto', 'yfrom', 'yto', 'km'] $
            , FIELDLOCATIONS:[0, 11, 24, 30, 34, 38, 40, 42] $
            , FIELDGROUPS:[0, 1, 2, 3, 4, 5, 6, 7] $
             }
endelse                 

return, templ         
         
end
