function asu_subst_map_name, name

case name of
  'useqt': begin
      name = "cycloLine.ZoneSearch.QT.Use"
  end
  'freefree': begin 
      name = "cycloCalc.ConsiderFreeFree"
  end
  'no_gst': begin 
      name = "cycloCalc.ConsiderFreeFree.Only"
  end
  'usealtlibrary': begin 
      name = "cycloCalc.Calculation.useAltLibrary"
  end
  'use_laplace': begin
      name = "cycloCalc.LaplasMethod.Use"
  end
  else: begin
      while (((pos = strpos(name, '_'))) ne -1) do strput, name, '.', pos
  end
endcase

return, name
  
end
