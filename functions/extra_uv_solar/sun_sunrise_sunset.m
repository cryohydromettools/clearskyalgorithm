function [decl_rad, sunrise_h, sunset_h, day_dur_h] = ...
          sun_sunrise_sunset(n_day_r,lat_deg)


% input
%###############################################################################
% attention: doubleprecision number (only a tradicional choise)
%###############################################################################

%decimal year day number (real)

%latitude (degrees)

% output

% locals
clear global;

persistent ang_hor_nascer decl_deg deg_rad lat_rad n_day_r_rad nascer_rad nascer_s por_s rad_deg ; 

% convert
if isempty(deg_rad), deg_rad=0; end
% convert
if isempty(rad_deg), rad_deg=0; end

% dia juliano em radianos (1 a 265)
if isempty(n_day_r_rad), n_day_r_rad=0; end
% decinacao em graus
if isempty(decl_deg), decl_deg=0; end

% decinacao em graus
if isempty(lat_rad), lat_rad=0; end

% nascer do sol em (rad)
if isempty(nascer_rad), nascer_rad=0; end
% nascer do sol em (s)
if isempty(nascer_s), nascer_s=0; end
% por do sol em (s)
if isempty(por_s), por_s=0; end
% periodo de sol em (h)
if isempty(ang_hor_nascer), ang_hor_nascer=0; end

% constants:

deg_rad=pi./180.;
rad_deg=180../pi;

% calculo da zero hora do dia juliano em radianos:

n_day_r_rad=(2.*pi./365.).*n_day_r;

%      write(*,*)'dia=',dia
%      write(*,*)'mes=',mes
%      write(*,*)'n_day_r=',n_day_r
%
% calculo da declinacao solar em radianos:

      decl_rad = 0.006918 - 0.399912*cos(n_day_r_rad)...
       +0.070257*sin(n_day_r_rad)-0.006758*cos(2.0*n_day_r_rad)...
       +0.000907*sin(2.0*n_day_r_rad)-0.002697*cos(3.0*n_day_r_rad)... 
       +0.00148*sin(3.0*n_day_r_rad);

%      write(*,*) 'declinacao solar(rad)=',decl_rad

% declinacao solar em graus:

decl_deg = decl_rad*rad_deg;

%      write(*,*) 'declinacao solar(graus)=',decl_deg
%
% calculo da latitude em radianos:

lat_rad = lat_deg*deg_rad;

%      write(*,*) 'latitude em graus    (lat_deg)=',lat_deg
%      write(*,*) 'latitude em radianos (lat_rad)=',lat_rad
%
% angulo horario do nascer do sol em radianos:

nascer_rad = acos((-tan(lat_rad).*tan(decl_rad)));

%      write(*,*) 'angulo horario do nascer do sol (rad)=',nascer_rad
%
% angulo horario do nascer do sol em (h) :

ang_hor_nascer = -( nascer_rad*12.0/pi );

% tempo local do nascer do sol em (h):

sunrise_h = (12. + ang_hor_nascer);

% tempo local do nascer do sol em (s):

nascer_s = sunrise_h .* 3600.;

% tempo local do por do sol em (h):

sunset_h = 12. - ang_hor_nascer;

% tempo local do por do sol em (s):

por_s = sunset_h .* 3600.;

% duracao total do periodo com sol em (h):

day_dur_h =( sunset_h - sunrise_h );

%      write(*,*) 'tempo local do nascer do sol (s) =',nascer_s
%      write(*,*)'tempo local do por do sol (s) = ',por_s
%
%      write(*,*) 'tempo local do nascer do sol (h) =',sunrise_h
%      write(*,*)'tempo local do por do sol (h) = ',sunset_h
%
%      write(*,*) 'periodo com sol em (h) =',day_dur_h,' h'

%----------------------------------------------------------------------
return;
end
%----------------------------------------------------------------------

