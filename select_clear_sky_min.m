%%  --------------  claer sky day algorithm  --------------  %%     

clc
clear all
close all

%%  --------------         dir work          --------------  %%     

dir_out            = ['data/output/'];
dir_graph          = ['graphics/']; 
dir_in             = ['data/input/'];
filename_in        = ['data_uv_340nm.txt'];
filename_out       = ['data_uv_340nm_cs_min.txt'];
filename_int_thres = ['first_thres.txt'];

%%  --------------  input year and location  --------------  %%     

years_total = [2018,2019,2020];
lon_s       = -75.30;
lat_s       = -12.04;
elv_s       = 3314.0;
zone_s      = -5;

%%  --------------   input conditions select  --------------  %%     

rsquare_in = 0.985;
rmse_in    = 0.04;
len_in     = 650;
bcoef      = 1.43;
r_fin      = 0.9;
dif_r      = 0.001;

%%  --------------        read data          --------------  %%     

str_total_dat = [dir_in,filename_in];
var_tot       = load(str_total_dat);

%%%%%%%%%% Arrays from data %%%%%%%%%%%%%%
year_input  = var_tot(:,1);
month_input = var_tot(:,2);
day_input   = var_tot(:,3);
hour_input  = var_tot(:,4);
min_input   = var_tot(:,5);
seg_input   = var_tot(:,6);
%%%%%%%%%% Irradiance final %%%%%%%%%%%%%
irra_340 = var_tot(:,7);

%%  --------------     read coeficients      --------------  %%     

str_total_thres = [dir_out,filename_int_thres];
thres_v         = load(str_total_thres);
     
sup_lim   = thres_v(1);
inf_lim01 = thres_v(2);
inf_lim02 = thres_v(3);


%% %%%%%%%%%%% calculate zenith angle %%%%%%%%%%%%%%%%%%%%%
for i = 1:length(year_input);
%location for site
location.longitude = lon_s; 
location.latitude  = lat_s; 
location.altitude  = elv_s;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time.year  = year_input(i);
time.month = month_input(i);
time.day   = day_input(i);  
time.hour  = hour_input(i);
time.min   = min_input(i);
time.sec   = seg_input(i);
time.UTC   = zone_s; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sun = sun_position(time, location);
zenith_input1(i) = sun.zenith;
end
zenith_input = zenith_input1';
%%
for k=1:ntotal

dt_local = datetime(year_input(k),month_input(k),day_input(k),...
                    hour_input(k),min_input(k),seg_input(k),...
                    'TimeZone','America/Lima');

dt_local.TimeZone  = 'UTC';

[year_utc,month_utc,day_utc,hour_utc,min_utc,seg_utc] = datevec(datenum(dt_local));

[year_r,month_r,day_r,hour_r,min_r,log_bissexto,n_day_r,n_days_year,...
year_rad] = year_02(year_utc,month_utc,day_utc,hour_utc,min_utc,seg_utc);

n_day_r = ( year_r - floor(year_r)) * n_days_year;

[decl_rad(k),sunrise_h(k),sunset_h(k),day_dur_h(k),ecce(k),extra_uv1(k)] =...
    extra_uv_rad(n_day_r,lon_s,lat_s,zenith_input(k));

end

%% %%%%%%%%%%%%%%%%% Input data must be in column  %%%%%%%%%%%%%%%%%%%%% %%
ntotal = length(zenith_input);

decimalyear = datenum([year_input,month_input,day_input,...
                       hour_input,min_input,seg_input]);

 while (dif_r > 10^-12)     

hour_cont_SW = hour_input + min_input/60.0 + seg_input/3600.0;

%%%%%%%%%%%%%%%%%%calculate normal irradiance%%%%%%%%%%%%%%
for i=1:ntotal

  if ( zenith_input(i) <= 90)
      
   irra_340_normal(i) = irra_340(i)/(cos(pi*zenith_input(i)/180)^bcoef);
   irra_340(i)        = irra_340(i);
   
  else
      
   irra_340_normal(i) = 0.0;
   irra_340(i)        = 0.0;

  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ntotal
    
    if (zenith_input(i) > 78.5)
    
    if ( irra_340_normal(i) >= inf_lim01 && irra_340_normal(i) <= sup_lim && ...
         zenith_input(i) < 90.0 )
        cs_year_SW(i)      = year_input(i);
        cs_month_SW(i)     = month_input(i);
        cs_day_SW(i)       = day_input(i);
        cs_hour_SW(i)      = hour_input(i);
        cs_minut_SW(i)     = min_input(i);
        cs_seg_SW(i)       = seg_input(i);
        cs_hour_cont_SW(i) = hour_cont_SW(i);
        cs_zenith_angle(i) = zenith_input(i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = irra_340(i);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    else 
        cs_year_SW(i)      = NaN;
        cs_month_SW(i)     = NaN;
        cs_day_SW(i)       = NaN;
        cs_hour_SW(i)      = NaN;
        cs_minut_SW(i)     = NaN;
        cs_seg_SW(i)       = NaN;
        cs_hour_cont_SW(i) = NaN;
        cs_zenith_angle(i) = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    end
    
    else
        
      if (irra_340_normal(i) >= inf_lim02 && irra_340_normal(i) <= sup_lim &&...
          zenith_input(i) < 90.0 )
        cs_year_SW(i)      = year_input(i);
        cs_month_SW(i)     = month_input(i);
        cs_day_SW(i)       = day_input(i);
        cs_hour_SW(i)      = hour_input(i);
        cs_minut_SW(i)     = min_input(i);
        cs_seg_SW(i)       = seg_input(i);
        cs_hour_cont_SW(i) = hour_cont_SW(i);
        cs_zenith_angle(i) = zenith_input(i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = irra_340(i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    else
        cs_year_SW(i)      = NaN;
        cs_month_SW(i)     = NaN;
        cs_day_SW(i)       = NaN;
        cs_hour_SW(i)      = NaN;
        cs_minut_SW(i)     = NaN;
        cs_seg_SW(i)       = NaN;
        cs_hour_cont_SW(i) = NaN;
        cs_zenith_angle(i) = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)   = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      end
    end
end

cs_zenith_1D = cs_zenith_angle(~isnan(cs_zenith_angle));
cs_irra_340_1D = cs_irra_340(~isnan(cs_irra_340));

rfin_prev = r_fin;
[r_fin,m_fin,b_fin] = regression(log(cos(pi*cs_zenith_1D /180)),log(cs_irra_340_1D));

bcoef = m_fin;
acoef = exp(b_fin);

dif_r = abs(r_fin - rfin_prev);

 end

