function [decl_rad,sunrise_h, sunset_h, day_dur_h,ecce, uv_top] = ...
                    extra_uv_rad(n_day_r,lon_deg, lat_deg,zenith_ang)
                            
                            %-------------------------------------------------------------------------------
% constants

clear global;
cons_solar_uv = 0.9552; % 1.0252
%-------------------------------------------------------------------------------

deg_rad = pi/180.0;
rad_deg = 180.0/pi;

%-------------------------------------------------------------------------------
% unidad conversion
%-------------------------------------------------------------------------------

lon_rad = lon_deg*deg_rad;
lat_rad = lat_deg*deg_rad;

% in radins
dj_rad =(2.0.*pi).*(n_day_r./365.);

%-------------------------------------------------------------------------------
% sunrise:
%-------------------------------------------------------------------------------

[decl_rad, sunrise_h,sunset_h,day_dur_h] = sun_sunrise_sunset(n_day_r,lat_deg);

ecce = 1.000110 + 0.034221.*cos(dj_rad) + 0.001280.*sin(dj_rad) + ...
       0.000719.*cos(2.0.*dj_rad) + 0.000077.*sin(2.0.*dj_rad);
   
cos_z = cos(zenith_ang*deg_rad);
   
 if( cos_z <= 0.0)
% night
  uv_top = 0.;
else
% day
  uv_top = cons_solar_uv.*ecce.*cos_z;
end
%-------------------------------------------------------------------------------
return;