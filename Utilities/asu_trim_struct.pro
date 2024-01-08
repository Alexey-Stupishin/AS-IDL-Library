function asu_trim_struct, s, idx_use, on_dims = on_dims
compile_opt idl2

if n_elements(on_dims) eq 0 then on_dims = [0, 1, 2, 3] 

max_idx = max(idx_use)
tags = tag_names(s)

new_s = !NULL
for k = 0, n_elements(tags)-1 do begin
    z = s.(k)
    zz = z
    sz = size(z)
    case sz[0] of
        1:  begin
                if sz[1] ge max_idx then begin
                    zz = z[idx_use]
                endif
            end

        2: begin
                if sz[on_dims[2]] ge max_idx then begin
                    case on_dims[2] of
                        1:  begin
                                zz = z[idx_use, *]
                            end
                        2:  begin
                            zz = z[*, idx_use]
                        end
                    endcase        
                endif
            end
            
        3: begin
                if sz[on_dims[3]] ge max_idx then begin
                    case on_dims[3] of
                        1:  begin
                                zz = z[idx_use, *, *]
                            end
                        2:  begin
                            zz = z[*, idx_use, *]
                        end
                        3:  begin
                            zz = z[*, *, idx_use]
                        end
                    endcase        
                endif
            end
    endcase
    
    new_s = create_struct(new_s, create_struct(tags[k], zz))
endfor

end
