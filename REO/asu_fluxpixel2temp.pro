; AGS Utilities collection
;   Conversion of the flux of the radiomap pixel to the brightness temperature in Kelvins
;   
; Call:
;   temperature = reo_fluxpixel2temp(flux, frequency, step)
; 
; Parameters description:
;   flux - flux from area of step^2 size
;   frequency - in GHz
;   step - in arcsec
;    
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2017-2020
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;

function asu_fluxpixel2temp, flux, frequency, step

return, asu_intensity2temp(flux/(2.35e8*step^2), frequency)

end
