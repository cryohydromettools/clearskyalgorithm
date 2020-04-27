%%  --------------  claer sky minutes algorithm  --------------  %%     

clc
clear all
close all

%%  --------------         dir work          --------------  %%     

dir_out            = ['data/output/'];
dir_graph          = ['graphics/']; 
dir_in             = ['data/input/'];
filename_in        = ['guv_data_all.txt'];
filename_out       = ['data_uv_340nm_cs_days.txt'];
filename_out_thres = ['first_thres.txt'];

%%  --------------  input year and location  --------------  %%     

years_total = [2018,2019,2020];
lon_s       = -75.30;
lat_s       = -12.04;
elv_s       = 3314.0;
zone_s      = -5;

%%  --------------  input conditions select day  --------------  %%     

rsquare_in = 0.985;
rmse_in    = 0.04;
len_in     = 650;
bcoef      = 1.43;

%%  --------------        read data          --------------  %%     

str_total_dat = [dir_in,filename_in];
var_tot       = load(str_total_dat);

%%%%%%%%%% Arrays from data %%%%%%%%%%%%%%
year_in  = var_tot(:,1);
month_in = var_tot(:,2);
day_in   = var_tot(:,3);
hour_in  = var_tot(:,4);
min_in   = var_tot(:,5);
seg_in   = var_tot(:,6);
%%%%%%%%%% Irradiance final %%%%%%%%%%%%%
irra_340 = var_tot(:,7);
%% repare time serie

t1      = int64(round(datenum([year_in(1),month_in(1),day_in(1),0,0,0])*24*60));
t2      = int64(round(datenum([year_in(end),month_in(end),day_in(end),23,59,0])*24*60));
t_total = [t1:1:t2]'; 
t_dat  = int64(round(datenum([year_in,month_in,day_in,hour_in,min_in,seg_in])*24*60));
Vector3 = table([t_total],'VariableNames',{'t_dat'});
Vector4 = table([t_dat],[var_tot]);
Data_sel = outerjoin(Vector3,Vector4,'Type','left');
[~,idx] = unique(Data_sel(:,1));
Data_sel = Data_sel(idx,:);
Data_sel1 = Data_sel.var_tot;
index_gaps = Data_sel1(:,1);
%%
t1 = datetime(datenum([year_in(1),month_in(1),day_in(1),0,0,0]),'ConvertFrom','datenum');
t2 = datetime(datenum([year_in(end),month_in(end),day_in(end),23,59,0]),'ConvertFrom','datenum');
t_total = (t1:minutes(1):t2)';
[yyyy_in,mm_in,dd_in,hou_in,min_in,sec_in] = datevec(t_total);

Data_sel1(:,1) = yyyy_in;
Data_sel1(:,2) = mm_in;
Data_sel1(:,3) = dd_in;
Data_sel1(:,4) = hou_in;
Data_sel1(:,5) = min_in;
Data_sel1(:,6) = sec_in;

year_input  = Data_sel1(:,1);
month_input = Data_sel1(:,2);
day_input   = Data_sel1(:,3);
hour_input  = Data_sel1(:,4);
min_input   = Data_sel1(:,5);
seg_input   = Data_sel1(:,6);

%%  --------------     read coeficients      --------------  %%     

summer_ind_24 = load([dir_in,'summer_ind_24.dat']);
autumn_ind_24 = load([dir_in,'autumn_ind_24.dat']);
winter_ind_24 = load([dir_in,'winter_ind_24.dat']);
spring_ind_24 = load([dir_in,'spring_ind_24.dat']);

%% %%%%%%%%%%% calculate zenith angle %%%%%%%%%%%%%%%%%%%%%
for i = 1:length(index_gaps);
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
%% %%%%%%%%% calculate extraterrestrial irradiance all days %%%%%%%%%%%% %%

for k=1:length(index_gaps)

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
extra_uv = extra_uv1';
%% Select season

Data_sel1 = [Data_sel1,extra_uv,zenith_input];

clear summer_dat12
x = find(Data_sel1(:,2)==12);
for i = 1:length(x)
       summer_dat12(i,:) = Data_sel1(x(i),:);
       
end
clear summer_dat1
x = find(Data_sel1(:,2)==1);
for i = 1:length(x)
       summer_dat1(i,:) = Data_sel1(x(i),:);
       
end
clear summer_dat2
x = find(Data_sel1(:,2)==2);
for i = 1:length(x)
       summer_dat2(i,:) = Data_sel1(x(i),:);
       
end
summer_dat = [summer_dat12;summer_dat1;summer_dat2];

clear spring_dat3
x = find(Data_sel1(:,2)==3);
for i = 1:length(x)
       spring_dat3(i,:) = Data_sel1(x(i),:);
       
end
clear spring_dat4
x = find(Data_sel1(:,2)==4);
for i = 1:length(x)
       spring_dat4(i,:) = Data_sel1(x(i),:);
       
end
clear spring_dat5
x = find(Data_sel1(:,2)==5);
for i = 1:length(x)
       spring_dat5(i,:) = Data_sel1(x(i),:);
       
end
spring_dat = [spring_dat3;spring_dat4;spring_dat5];

clear winter_dat6
x = find(Data_sel1(:,2)==6);
for i = 1:length(x)
       winter_dat6(i,:) = Data_sel1(x(i),:);
       
end
clear winter_dat7
x = find(Data_sel1(:,2)==7);
for i = 1:length(x)
       winter_dat7(i,:) = Data_sel1(x(i),:);
       
end
clear winter_dat8
x = find(Data_sel1(:,2)==8);
for i = 1:length(x)
       winter_dat8(i,:) = Data_sel1(x(i),:);
       
end
winter_dat = [winter_dat6;winter_dat7;winter_dat8];

clear autumn_dat9
x = find(Data_sel1(:,2)==9);
for i = 1:length(x)
       autumn_dat9(i,:) = Data_sel1(x(i),:);
       
end
clear autumn_dat10
x = find(Data_sel1(:,2)==10);
for i = 1:length(x)
       autumn_dat10(i,:) = Data_sel1(x(i),:);
       
end
clear autumn_dat11
x = find(Data_sel1(:,2)==11);
for i = 1:length(x)
       autumn_dat11(i,:) = Data_sel1(x(i),:);
       
end
autumn_dat = [autumn_dat9;autumn_dat10;autumn_dat11];
%% %%%%%%%%%%%%  calculate surface irradiance from ext  %%%%%%%%%%%%%%%% %%
% summer
x1 = 1;
x2 = 1440;
surf_uv_summer_all = [];
for i = 1:(length(summer_dat)/1440)
    extra_summer_day    = summer_dat(x1:x2,16);
    surf_uv_summer_day  = extra_summer_day .* summer_ind_24;
    x1 = x2 + 1;
    x2 = x2 + 1440;
surf_uv_summer_all = [surf_uv_summer_all;surf_uv_summer_day];
end

% spring
x1 = 1;
x2 = 1440;
surf_uv_spring_all = [];
for i = 1:(length(spring_dat)/1440) 
    extra_spring_day    = spring_dat(x1:x2,16);
    surf_uv_spring_day  = extra_spring_day .* spring_ind_24;
    x1 = x2 + 1;
    x2 = x2 + 1440;
surf_uv_spring_all = [surf_uv_spring_all;surf_uv_spring_day];
end

% winter
x1 = 1;
x2 = 1440;
surf_uv_winter_all = [];
for i = 1:(length(winter_dat)/1440)
    extra_winter_day    = winter_dat(x1:x2,16);
    surf_uv_winter_day  = extra_winter_day .* winter_ind_24;
    x1 = x2 + 1;
    x2 = x2 + 1440;
surf_uv_winter_all = [surf_uv_winter_all;surf_uv_winter_day];
end
% autumn
x1 = 1;
x2 = 1440;

surf_uv_autumn_all = [];
for i = 1:(length(autumn_dat)/1440)
    extra_autumn_day    = autumn_dat(x1:x2,16);
    surf_uv_autumn_day  = extra_autumn_day .* autumn_ind_24;
    x1 = x2 + 1;
    x2 = x2 + 1440;
surf_uv_autumn_all = [surf_uv_autumn_all;surf_uv_autumn_day];
end

surf_uv_all = [surf_uv_summer_all;surf_uv_spring_all;surf_uv_winter_all;surf_uv_autumn_all];
%% order data
Data_all = [summer_dat;spring_dat;winter_dat;autumn_dat];
date_num  = datenum(Data_all(:,1),Data_all(:,2),Data_all(:,3),Data_all(:,4),Data_all(:,5),Data_all(:,6));
data_all  = [date_num,Data_all,surf_uv_all];
[~,idx] = sort(data_all(:,1)); 
data_all1 = data_all(idx,:); 
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

