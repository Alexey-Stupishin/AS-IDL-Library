pro asu_gxm_dressing_model_prepare, model $
    , position_angle = position_angle $
    , xc = xc, yc = yc, xfov = xfov, yfov = yfov, nx = nx, ny = ny $
    , _extra=_extra $
    , fovdata = fovdata

    default, position_angle, 0d

    model->SetProperty, gyro = position_angle
    fovdata = model->SetFOV(xc = xc, yc = yc, xfov = xfov, yfov = yfov, nx = nx, ny = ny, /compute_grid)

end