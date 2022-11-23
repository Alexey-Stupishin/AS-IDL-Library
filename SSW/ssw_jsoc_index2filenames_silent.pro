function ssw_jsoc_index2filenames_silent, index, time_tag=time_tag, $
   parent_out=parent_out, _extra=_extra , chrontree=chrontree, t_obs=t_obs, $
   mkdir=mkdir, ext=ext
;
;+
;   Name: ssw_jsoc_index2filenames
;
;   Purpose: jsoc meta data /  SSW "index" -> file names, opt with tree
;
;   Input Paramters:
;      index - meta data / index vector
;
;   Keyword Paramters:
;      parent_out - optional parent path (-> ssw_time2paths)
;       _extra=_extra - optional chron tree organization (-> ssw_time2paths)
;      time_tag - optional index.<TIME_TAG> - def looks for:
;                 (1. DATE__OBS 2. T_OBS( -.5*EXPTIME)
;      chrontree (switch) - if set, return full path like:
;                           <parent_out>/yyyy/mm/dd/Hhhhh/<filename>
;      t_obs (switch) - if set, and T_OBS exists, preferentially use that
;      mkdir (switch) - if set, create non-existent directories
;                       (parent_out and/or /CHRONTREE set)
;      ext - optional file extension - default='.fits'
;
;   History:
;      ~2009 - S.L.Freeland
;     9-jul-2010 - S.L.Freeland - remove prepeded SDO_ (prefix is AIA_ or HMI_)
;    21-sep-2010 - S.L.Freeland - add /T_OBS and /CHRONTREE keywords
;                  swap wave<->time <parent_out>/{AIA/HMI}yyyymmdd_hhmmss_<wave>.fits
;

nout=n_elements(index)
if nout eq 0 then begin 
   box_message,'Expect input index vector...
   return,''
endif

date_obs=gt_tagval(index(0),/date_obs,missing='')
case 1 of 
   data_chk(time_tag,/string): times=gt_tagval(index,time_tag,missing=time_tag)
   tag_exist(index,'t_obs') and keyword_set(t_obs): times=index.t_obs
   tag_exist(index,'date_obs'): times=index.date_obs
   tag_exist(index,'date__obs'): times=index.date__obs
   tag_exist(index,'t_obs'): times= $
      anytim(anytim(index.t_OBS)- (.5*gt_tagval(index,/exptime,missing=0)),/ecs)
   else: begin 
      ; box_message,'Cannot find expected TIMEs - use TIME_TAG next time?
      return,'dummy_notimes_'+ string(sindgen(n_elements(index)),format='(I4.4)')
   endcase
endcase

instr=strmid(strtrim(gt_tagval(index,/instrume,missing=$
         gt_tagval(index,/telescop,missing='')),2),0,3)

if strpos(instr(0),'/') ne -1 then instr=ssw_strsplit(instr,'/',/tail)
;if instr(0) ne '' then instr=instr+'_'

wave=strcompress(string(gt_tagval(index,/wavelnth,missing='0000'),format='(i4.4)'),/remove)
ssbad=where(wave eq '****',bcnt)
if bcnt gt 0 then wave[ssbad]=''
if wave(0) ne '' then wave='_' + wave

if data_chk(ext,/string) then ext='.'+str_replace(ext,'.','') else ext='.fits'
fname=instr + time2file(times,/sec) + wave + ext 


retval=fname

chrontree=keyword_set(chrontree)
if n_elements(parent_out) ne  0 then begin 
   if n_elements(parent_out) eq 0 then parent_out=curdir()
   mkdir=keyword_set(mkdir)
   topdirs=parent_out ; don't clobber input
   if chrontree then $ 
      topdirs=ssw_time2paths(times=times,parent=parent_out,/hour)
   if mkdir then mk_dir,topdirs(uniq(topdirs))
   retval=concat_dir(topdirs,retval)   ;
endif

return,retval
end
 
