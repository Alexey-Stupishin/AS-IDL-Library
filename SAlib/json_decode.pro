function json_decode_byte,jsonb,strmask,level
  curlevel=level[0]
  openA=(byte('['))[0]
  openS=(byte('{'))[0]
  closeA=(byte(']'))[0]
  closeS=(byte('}'))[0]
  quote=(byte('"'))[0]
  ;stop
  if jsonb[0] eq openS then begin
  n=n_elements(jsonb)
    jsonb=jsonb[1:n-2]
    strmask=strmask[1:n-2]
    level=level[1:n-2]
    ind =where((jsonb eq (byte(','))[0]) and (level eq curlevel) and (strmask eq 0b))
    st=0
    if ind[0] ge 0 then begin
      for i=0,n_elements(ind) do begin
        if i eq 0 then st =0 else st=ind[i-1]+1
        if i eq n_elements(ind) then en=n_elements(jsonb)-1 else en=ind[i]-1
        tmp=jsonb[st:en]
        tmpstr=strmask[st:en]
        tmplvl=level[st:en]
        ind2=where((tmp eq (byte(':'))[0]) and (tmplvl eq curlevel) and (tmpstr eq 0b))
        foo=tmp[0:ind2[0]-1]
        tag=foo[where(foo ne quote)]
        foo=tmp[ind2[0]+1:*]
        value=json_decode_byte(foo,tmpstr[ind2[0]+1:*],tmplvl[ind2[0]+1:*])
        if keyword_set(result) then result=create_struct(string(tag),value,result) else result=create_struct(string(tag),value)
       endfor
     endif else begin
        ind2=where((jsonb eq (byte(':'))[0]) and (level eq curlevel) and (strmask eq 0b))
        foo=jsonb[0:ind2[0]-1]
        tag=foo[where(foo ne quote)]
        foo=jsonb[ind2[0]+1:*]
        value=json_decode_byte(foo,strmask[ind2[0]+1:*],level[ind2[0]+1:*])
        result=create_struct(string(tag),value)
     endelse 
    return,result
  endif
  if jsonb[0] eq openA then begin
  n=n_elements(jsonb)
    jsonb=jsonb[1:n-2]
    strmask=strmask[1:n-2]
    level=level[1:n-2]
    ind =where((jsonb eq (byte(','))[0]) and (level eq curlevel) and (strmask eq 0b))
    st=0
    if ind[0] ge 0  then begin
      for i=0,n_elements(ind) do begin
        if i eq 0 then st =0 else st=ind[i-1]+1
        if i eq n_elements(ind) then en=n_elements(jsonb)-1 else en=ind[i]-1
        tmp=jsonb[st:en]
        tmpstr=strmask[st:en]
        tmplvl=level[st:en]
        value=json_decode_byte(tmp,tmpstr,tmplvl)
        if keyword_set(result) then result=[result,value] else result=value;string(value)
       endfor
     endif else result=[json_decode_byte(jsonb,strmask,level)]
    return,result
  endif
  if jsonb[0] eq quote then begin
     if n_elements(jsonb)le 2 then return,''
     return, string(jsonb[1:n_elements(jsonb)-2])
  endif   
  return,float(string(jsonb))
end
function json_decode,json
;json='{"ab" : [1,2,3,4] ,"bc" : {"st":"sdgs","en":"foo"}}'
  jsonb=byte(json)
  levels=jsonb*0
  openA=(byte('['))[0]
  openS=(byte('{'))[0]
  closeA=(byte(']'))[0]
  closeS=(byte('}'))[0]
  quote=(byte('"'))[0]
  ind = where(jsonb gt 32);remove special characters
  jsonb=jsonb[ind]
  strmask=jsonb*0
  ind=where(jsonb eq quote);mark characters inside quotes
  strmask(ind)=1
  strmask=total(strmask,/cum) mod 2
  strmask[ind]=0
  indo=where(jsonb eq openA or jsonb eq opens)
  indc=where(jsonb eq closeA or jsonb eq closes)
  level=jsonb*0
  level[indo]=1
  level[indc]=-1
  level=total(level,/cum)
  level[indc]+=1 
  return,json_decode_byte(jsonb,strmask,level)
end