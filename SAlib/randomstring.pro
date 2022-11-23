function randomstring,seed,length
  common randomstring_common,s
  if not keyword_set(seed) then begin
     if keyword_set(s) then seed = s else $
      seed= systime(/sec)+parallel_id()*10000d
  endif
  if n_params() eq 0 then begin
    s = seed
    length = 5    
  endif
  if n_params() eq 1 then length=seed>1 else s=seed
  if not keyword_set(s) then s= systime(/sec)+parallel_id()*10000d
  result = string(byte(97+25*randomu(s,length)));+strcompress(parallel_id(),/remove_all)
  if n_params() eq 2 then seed=s 
  return,result 
end