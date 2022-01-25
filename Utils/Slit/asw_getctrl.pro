function asw_getctrl, uname

common G_ASW_WIDGET, asw_widget

return, widget_info(asw_widget['widbase'], find_by_uname = uname)

end
