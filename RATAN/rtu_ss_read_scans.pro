pro rtu_ss_read_scans, filename $ ; in
                     , mainstr, parstr, points, freqs, right, left, quiet ; out

openr, fnum, filename, /GET_LUN 

line = ''
fstate = 'header'
mainstr = !NULL
parstr = !NULL
while ~eof(fnum) do begin
    readf, fnum, line
    case fstate of
        'header': begin
            cstate = rtu_ss_read_headline(line, sect, key, value)
            print, sect, '.', key, ' = ', value
            if strcmp(sect, 'MAIN') then begin
                mainstr = create_struct(key, value, mainstr)
                if strcmp(key, 'N_FREQS') then n_freqs = fix(value)
                if strcmp(key, 'N_POINTS') then n_points = fix(value)
            endif
            if strcmp(sect, 'PAR') then begin
                parstr = create_struct(key, value, parstr)
            endif
            if cstate eq -1 then begin ; read data header
                points = dblarr(n_points)
                freqs = dblarr(n_freqs)
                right = dblarr(n_points, n_freqs)
                left = dblarr(n_points, n_freqs)
                quiet = dblarr(n_points, n_freqs)
                
                ; fill data header
                out = double(strsplit(line, ' ', /EXTRACT))
                shift = out[0]
                mainstr = create_struct('shift', shift, mainstr)
                for k = 0, n_freqs-1 do freqs[k] = out[3*k + 1]
                
                fstate = 'data'
                cnt = 0
            end
        end
        else: begin
            out = double(strsplit(line, ' ', /EXTRACT))
            points[cnt] = out[0]
            for k = 0, n_freqs-1 do begin
                right[cnt, k] = out[3*k + 1]
                left[cnt, k]  = out[3*k + 2]
                quiet[cnt, k] = out[3*k + 3]
            endfor
            cnt++
            if cnt ge n_points then break
        end
    endcase
endwhile

free_lun, fnum

end
