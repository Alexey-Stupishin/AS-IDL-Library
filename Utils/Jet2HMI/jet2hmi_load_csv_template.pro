function jet2hmi_load_csv_template

template =  {VERSION:1.0, DATASTART:0, DELIMITER:',', MISSINGVALUE:-99999999, COMMENTSYMBOL:'' $
        , FIELDCOUNT:16 $
        , FIELDTYPES:[7, 7, 7, 3, 7, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4] $
        , FIELDNAMES:['tstart', 'tmax', 'tend', 'N', 'duration', 'maxcard', 'jet_aspect', 'max_aspect', 'l2w_aspect', 'speed', 'length', 'width', 'xfrom', 'xto', 'yfrom', 'yto'] $
        , FIELDLOCATIONS:[0, 11, 24, 30, 34, 38, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130] $
        , FIELDGROUPS:[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] $
         }
         
return, template         
         
end
