function asu_download_code_message, code

CASE code OF
      0: s = 'Successful'
     -1: s = 'No meta information returned'
     -2: s = 'Query returns no URLs'
     -3: s = 'Too many downloads failed'
     -4: s = 'Postponed downloads failed'
   else: s = 'Undefined error code'
ENDCASE

return, s

end
