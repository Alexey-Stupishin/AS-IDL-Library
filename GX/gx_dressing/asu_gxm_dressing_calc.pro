function asu_gxm_dressing_calc, model, Q0, a, b, freqlist $
                     , ebtel_path = ebtel_path, renderer = renderer, info = info $
                     , _extra=_extra

    default, ebtel_path, gx_findfile('ebtel.sav', folder = '')
    default, renderer, gx_findfile('grffdemtransfer.pro', folder = '')
  
    ; map=obj_new('map')
     t0=systime(/s)
     q0_formula='q[0]'
     q_formula = string(a, b, format = "('q0*(B/q[1])^(',g0,')/(L/q[2])^(',g0,')')")
     q_parms=[q[j], 100.0, 1.0000000d+009, 0.0, 0.0]
     map = gx_mwrender_ebtel(model, renderer, info = info, ebtel_path = ebtel_path $
         , q_parms = q_parms, q_formula = q_formula, q0_formula = q0_formula $
         , gxcube = gxcube, freqlist = freqlist, /flux, _extra = _extra)

     return, map
     
  end