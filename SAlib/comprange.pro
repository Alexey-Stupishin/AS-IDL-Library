function gaussf,n,sigm
  if n_elements(sigm) ne 1 then sigm=3.
  x=findgen(n)-0.5*(float(n)-1.)
  return,1/(sqrt(2*!pi)*sigm)*exp(-x*x/(2*sigm*sigm))
end
function gausssmooth,data,width
  data=reform(temporary(data))
  dim=size(data)
  if ~keyword_set(width) then message, 'second parameter is required'
  widthi=float(width)*0.5
  sm=fltarr(dim(0))
  if n_elements(widthi) eq 1 then begin 
    sm=sm+widthi
  endif else begin
    sm(0:(n_elements(widthi)<dim(0))-1)=widthi(0:(n_elements(width)<dim(0))-1)
  endelse 
  case dim(0) of
    1: begin 
        dat=data
        if sm[0] le 0.5 then return,dat
        n=(ceil(sm[0]*3)*2+1)<dim[1]
        ker=gaussf(n,sm[0])
        dat=convol(temporary(dat),ker,total(ker),/edge_trunc,/normal)
        return,reform(temporary(dat))       
       end
       
       
    2: begin
        dat=data
        for i=0,1 do begin
              if sm[i] le 0.5 then continue
              n=(ceil(sm[i]*3)*2+1)<min(dim[1:2])
              ker=gaussf(n,sm[i])
            case i of
              0: ker=reform(ker,n,1)
              1: ker=reform(ker,1,n)
            endcase
            dat=convol(temporary(dat),ker,/edge_trunc,/normal)
          endfor
          return,reform(temporary(dat))
       end 
    3: begin
          dat=data
          for i=0,2 do begin
            if sm[i] le 0.5 then continue
            n=ceil(sm[i]*3)*2+1
            ker=gaussf(n,sm[i])
          case i of
            0: ker=reform(ker,n,1,1)
            1: ker=reform(ker,1,n,1)
            2: ker=reform(ker,1,1,n)
          endcase
          dat=convol(temporary(dat),ker,/edge_trunc,/normal)
         endfor
        return,reform(temporary(dat))
      end
  endcase
  
end
Function Get_local_averrage,im  
  nx=(size(im))[1]
  ny=(size(im))[2]
  n=15.
  s=1.5
  ds=1.2
  e=0.1
  sm=gausssmooth(im,1.3)
  mask=replicate(1.0,nx,ny)
  res=im*0.
  a=1.0
  for i=0,6 do begin

    smnext=gausssmooth(im,s)
    s=s*ds
    v=mask*(sm-smnext)/(sm)
    ind = where(v gt e)
     sm=smnext 
   ;print,i,s
     if ind[0] lt 1 then continue
    res[ind]=sm[ind]
    mask[ind]=0.
   
    ;tvscl,v
    ;wait,1
  endfor
  ind=where(mask gt 0)
  res[ind]=sm[ind]
  ;tvscl,res
  ;print,minmax(res)
  ;print,minmax(im)
  return,res  
end
function comprange,image,param,local=local,global=global
  dim=size(image)
  if dim[0] eq 3 then begin
    res=image*0.   
    for i=0,dim[3]-1 do res[*,*,i]=comprange(reform(image[*,*,i]),param,local=local,global=global)
    return,res
  endif
  if not keyword_set(param) then param=1.0
  if not keyword_set(global) then local=1
  im=image
  im-=min(im)
  IM/=MEAN(IM)*param
  if keyword_set(local) then begin
     la=Get_local_averrage(im)
     return,alog(1.0+(temporary(im))/(temporary(la)+1.0))
  endif
  ;
  ;lwhite=mean(im)*param
  ;return,bytscl(im*(1.+im/lwhite^2)/(1.+im))
  return,im/(1.+im)
  ;im2=im/(1.+im)

end