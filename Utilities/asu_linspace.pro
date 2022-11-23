; AGS Utilities collection
;   Classic linspace implementation (arithmetic progression from 'from' to 'to' with 'N' steps)
;   
; Call:
; linarray = asu_linspace(from, to, N)
; 
; Parameters description: (obviously, but will be defined)
;    
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2017-2020
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;
                                                          
function asu_linspace, from, to, N

return, dindgen(N)*(to - from)/(N-1) + from 

end
