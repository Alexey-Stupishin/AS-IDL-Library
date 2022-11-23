function encode_url,struct
  tags=strlowcase(tag_names(struct))
  vars=strarr(n_elements(tags))
  for i=0,n_elements(tags)-1 do vars[i]=tags[i]+'='+sstring(struct.(i))
  return,strjoin(vars,'&')
end
Function jsoc_get_urls,query,directory,requestid=requestid,processing=processing, file_names = file_names
  status=['OK immediate data available','processing','queued for processing','large request needs manual confirm', $
  'bad recordset','request not formed correctly, bad series, etc.','request old, results requested after data timed out', $
  'RequestID not regognized, probably need to repeat in a few seconds']
  url_host='jsoc.stanford.edu'
  url_path='/cgi-bin/ajax/jsoc_fetch'
  url_query=''
  oUrl = OBJ_NEW('IDLnetUrl',url_host=url_host,url_path=url_path,url_query=url_query)
  if not keyword_set(processing) then processing="n%3d0,no_op"
  if not keyword_set(requestid) then begin
    params={op:'exp_request', protocol:'fits,compress rice',method:'url',ds:query,filenamefmt:'{seriesname}.{T_OBS:A}.{CAMERA}.{segment}',process:processing, notify: 'sergey.istp@gmail.com'}

    ourl->SetProperty,url_query=encode_url(params)
      message,'Connecting to JSOC Server',/info
    buf=strjoin(ourl->get(/string),'')  
    response=json_decode(buf(0))
    if response.status ge 3 then message,response.error
    if response.rcount eq 0 then message,'ERROR, no data available for query: "'+query+'"'  
    requestid=response.requestid
    message,'Answer: '+status[response.status]+'  REQUEST ID is '+response.requestid,/info
    delay=fix(response.wait)<15>7
    message,'waiting '+sstring(response.wait)+' seconds',/info
  endif else delay=20

  for i=0,1200 do begin
    wait,delay
    oUrl->SetProperty,url_query=encode_url({op:'exp_status',requestid:requestid})
    buf=ourl->get(/string)
    response=json_decode(strjoin(buf,''))
    if (response.status ge 3) and (response.status ne 6)  then message,response.error
    ;message,'Answer: '+status[response.status],/info
    if response.status eq 0 then break
	delay=10;fix(response.wait)<15>10    
    message,'remote processing, waiting '+sstring(delay)+' seconds',/info
  endfor
  OBJ_DESTROY, oUrl 
  dir=str_replace(response.dir,'\/','/')
  if response.method eq 'url-tar' then begin
    tarfile = strreplace(response.tarfile,'\/','/')
    return, 'http://jsoc.stanford.edu'+tarfile
  endif
  nf=n_elements(response.data)
  links='http://jsoc.stanford.edu'+str_replace(response.dir,'\/','/')+'/'+response.data.filename
  directory='http://jsoc.stanford.edu'+str_replace(response.dir,'\/','/')
  file_names = response.data.filename
  return, 'http://jsoc.stanford.edu'+str_replace(response.dir,'\/','/')+'/'+response.data.filename
end