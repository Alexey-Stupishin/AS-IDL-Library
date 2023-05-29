;--------------------------------------------------------------;
;     \|/     Here comes the Sun,                     \|/      ;
;    --O--    Here comes the Sun, and I'd say        --O--     ;
;     /|\     "It's alright"                          /|\      ;                   
;                 The Beatles, "Abbey Road", 1968              ;  
;--------------------------------------------------------------;

function asu_gxm_gsff_renderer, model, q0, qB, qL, f1, df, n_freq $
                              , renderer = renderer, ff_only = ff_only, Smax = Smax

default, renderer, 'mwgr_transfer_nonlte'
default, ff_only, 0
default, Smax, 5
dist_e = ff_only ? 1 : 2

setenv, 'WCS_RSUN=6.96d8'; solar radius assumed by GX AMPP
q0_formula = 'q[0]';volumetric heating rate formula
q_formula = 'q0*(B/q[1])^q[3]*(L/q[2])^q[4]';volumetric heating formula
path = gx_ebtel_path('ebtel.sav'); select a specific EBTEL table

corona = model->Corona()
corona->SetProperty, dist_e = dist_e
corona->SetProperty, Smax = Smax

q = [q0, 100d, 1d9, qB, qL]
maps = gx_mwrender_ebtel(model, renderer, q_parms = q, q0_formula = q0_formula $
                       , q_formula = q_formula, f_min = f1, df = df, n_freq = n_freq)
        
return, maps
                                 
end
