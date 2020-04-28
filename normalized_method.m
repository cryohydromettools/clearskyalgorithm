% Normalized method
%
% Normalized method is based on the calculation of normalized UV 
% irradiance measured at 340 nm with one minute interval, using the power 
% law equation of the cosine of the solar zenith angle (SZA). This method 
% was used to identify clear sky Global irradiance by 
% Long and Ackerman (2000) and UV irradiance by Suárez Salas et al. (2017).
% The power law equation depending a and b regression coefficients. 
% The a coefficient determine maximum (sup_lim) and 
% minimum (inf_lim01, inf_lim02) threshold for our data set. The 
% automation process to detect the a and b (bcoef) coefficients, which are 
% representative of the entire irradiance dataset, lies in iteration. For 
% first iteration, it can be proposed initial coefficients take from 
% the scientific literature or found clear sky day using wavelet transform 
% method. In our case, e.g., for first iteration, these initial 
% coefficients were obtained from the scientific literature 
% (e.g., Suárez Salas et al., 2017), bcoef equal to 1.30, sup_lim equal 
% to 0.82 W m^{-2}, inf_lim01 equal to 0.62 W m^{-2} and inf_lim02 to 
% 0.58 W m^{-2}. After the first iteration, the algorithm uses the results 
% from fitting the previosly detected clear sky measurements,and succeeding
% iterations refine the process to the actual characteristics of the 
% themselves. The final values for the coefficients are obtained after 
% the automation process.    
%
%%%%%%%%%%  Input parameters: %%%%%%%%%%%
%%%%%%%%%%%    dir work section   %%%%%%%%%%%
%	
%	dir_out            = dir output
%	dir_graph          = dir graphics 
%	dir_in             = dir input
%	filename_in        = file name data set
%    
%%%%%%%%%%%   input years and location section %%%%%%%%%%%
%	
%	years_total = years work e.g. [2018,2019,2020]
%	lon_s       = logitude   e.g. [-75.30]
%	lat_s       = latiude    e.g. [-12.04]
%	elv_s       = elevation  e.g. [3314.0]
%	zone_s      = zone UTC   e.g. [-5]
%
%%%%%%%%%%%    conditions select day  section %%%%%%%%%%%    
%
%	bcoef       = b coefficient initial     e.g. [1.30]
%	sup_lim     = threshold max             e.g. [0.82]
%	inf_lim01   = threshold min < 78.5° SZA e.g. [0.62] 
%	inf_lim02   = threshold min > 78.5° SZA e.g. [0.58]
%
%%%%%%%%%%     Output data:   %%%%%%%%%%%
%
%	filename_out       = file output name normalized method 
%
% References
%
% Long, C. N., and Ackerman, T. P. (2000). Identification of clear skies 
% from broadband pyranometer measurements and calculation of downwelling 
% shortwave cloud effects. Journal of Geophysical Research: Atmospheres, 
% 105(D12), 15609-15626. https://doi.org/10.1029/2000JD900077
%
% Suárez Salas, L. F., Flores Rojas, J. L., Pereira Filho, A. J., and 
% Karam, H. A. (2017). Ultraviolet solar radiation in the tropical central 
% Andes (12.0°S). Photochemical & Photobiological Sciences, 16(6), 954-971. 
% https://doi.org/10.1039/C6PP00161K

%%  --------------     normalized method     --------------  %%     

clc
clear all
close all

%%  --------------         dir work          --------------  %%     

dir_out            = ['output/'];
dir_graph          = ['graphics/']; 
dir_in             = ['input/'];
filename_in        = ['guv_data_all_f.txt'];
filename_out       = ['cs_data_uv_min_met2.txt'];

%%  --------------  input year and location  --------------  %%     

years_total = [2018,2019,2020];
lon_s       = -75.30;
lat_s       = -12.04;
elv_s       = 3314.0;
zone_s      = -5;

%%  --------------  input conditions clear sky select  --------------  %%     

bcoef      = 1.30; % coeficient b initial
sup_lim    = 0.82; % maximum limit
inf_lim01  = 0.62; % minimum limit < 78.5° 
inf_lim02  = 0.58; % minimum limit > 78.5°

% opcional changes

len_in     = 600;  % oneminute measurements 
dif_r      = 0.1;  % condition convergente
r_fin      = 0.9;  %  

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
irra_305 = var_tot(:,7);
irra_320 = var_tot(:,8);
irra_340 = var_tot(:,9);
irra_380 = var_tot(:,10);
dose_mean = var_tot(:,12);

%% %%%%%%%%%%% calculate zenith angle %%%%%%%%%%%%%%%%%%%%%

ntotal = length(year_input);
for i = 1:ntotal;
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
var_tot = [var_tot,zenith_input];

%% %%%%%%%%%%%%%% Input data must be in column summer %%%%%%%%%%%%%%%%%% %%

decimalyear = datenum([year_input,month_input,day_input,...
                       hour_input,min_input,seg_input]);

 while (dif_r > 10^-5)     

hour_cont_SW = hour_input + min_input/60.0 + seg_input/3600.0;

%%%%%%%%%%%%%%%%%%calculate normal irradiance%%%%%%%%%%%%%%

for i=1:ntotal

  if ( zenith_input(i) <= 85)
      
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
         zenith_input(i) < 85.0 )

        cs_year_guv(i)      = year_input(i);
        cs_month_guv(i)     = month_input(i);
        cs_day_guv(i)       = day_input(i);
        cs_hour_guv(i)      = hour_input(i);
        cs_minut_guv(i)     = min_input(i);
        cs_seg_guv(i)       = seg_input(i);

        cs_zenith_angle(i) = zenith_input(i);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = irra_340(i);
        cs_irra_305(i)     = irra_305(i);
        cs_irra_320(i)     = irra_320(i);
        cs_irra_380(i)     = irra_380(i);
        cs_dose_mean(i)    = dose_mean(i);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    else 
        cs_year_guv(i)      = NaN;
        cs_month_guv(i)     = NaN;
        cs_day_guv(i)       = NaN;
        cs_hour_guv(i)      = NaN;
        cs_minut_guv(i)     = NaN;
        cs_seg_guv(i)       = NaN;
        cs_zenith_angle(i) = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = NaN;
        cs_irra_305(i)     = NaN;
        cs_irra_320(i)     = NaN;
        cs_irra_380(i)     = NaN;
        cs_dose_mean(i)    = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    end
    
    else
        
      if (irra_340_normal(i) >= inf_lim02 && irra_340_normal(i) <= sup_lim &&...
          zenith_input(i) < 85.0 )
        cs_year_guv(i)      = year_input(i);
        cs_month_guv(i)     = month_input(i);
        cs_day_guv(i)       = day_input(i);
        cs_hour_guv(i)      = hour_input(i);
        cs_minut_guv(i)     = min_input(i);
        cs_seg_guv(i)       = seg_input(i);
        cs_zenith_angle(i) = zenith_input(i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = irra_340(i);
        cs_irra_305(i)     = irra_305(i);
        cs_irra_320(i)     = irra_320(i);
        cs_irra_380(i)     = irra_380(i);
        cs_dose_mean(i)    = dose_mean(i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    else
        cs_year_guv(i)      = NaN;
        cs_month_guv(i)     = NaN;
        cs_day_guv(i)       = NaN;
        cs_hour_guv(i)      = NaN;
        cs_minut_guv(i)     = NaN;
        cs_seg_guv(i)       = NaN;
        cs_zenith_angle(i)  = NaN;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cs_irra_340(i)     = NaN;
        cs_irra_305(i)     = NaN;
        cs_irra_320(i)     = NaN;
        cs_irra_380(i)     = NaN;
        cs_dose_mean(i)    = NaN;
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

cs_total = [cs_year_guv',cs_month_guv',cs_day_guv',cs_hour_guv',...
            cs_minut_guv',cs_seg_guv',cs_irra_305',cs_irra_320',cs_irra_340',...
            cs_irra_380',cs_dose_mean'];

%% save data clear sky all

str_total_out = [dir_out,filename_out];
dlmwrite(str_total_out,cs_total,'delimiter',' ','precision','%.3f');

%% Generate plot

log_cos_zenith_reg = linspace(-10,1.0,100);
log_cs_global_reg = m_fin.*log_cos_zenith_reg + b_fin;
 
figure1 = figure('Color',[1 1 1], 'visible','off','DefaultAxesPosition', [0.15, 0.15, 0.80, 0.8]);
x0 = 10; y0 = 10;
width  = 480;
height = 420;
set(gcf,'PaperPositionMode','auto');
set(figure1,'units','points','position',[x0,y0,width,height]);
plot(log(cos(pi*cs_zenith_angle/180)),log(cs_irra_340),'r.');
xlabel('Ln[cos(SZA)]','FontSize',12);
ylabel('Ln(lsc, 340)','FontSize',12);
axis([-4 0.5 -5 0.5]);
set(gca,'XTick',(-10:0.5:1.0),'FontSize',16);
set(gca,'YTick',(-5:0.5:8),'FontSize',16); 
hold on
if b_fin > 0
text(-1.5,-3.3,['Y = ' num2str((m_fin)),'*X',' + ',num2str((b_fin))],'FontSize',16)
text(-1.5,-3.7,['R^2 = ' num2str(r_fin)],'FontSize',16)
text(-1.5,-4.1,['a = ' num2str(exp(b_fin))],'FontSize',16)
text(-1.5,-4.5,['b = ' num2str(m_fin)],'FontSize',16)

elseif b_fin < 0
text(-1.5,-3.3,['Y = ' num2str((m_fin)),'*X',' + ',num2str((b_fin))],'FontSize',16)
text(-1.5,-3.7,['R^2 = ' num2str(r_fin)],'FontSize',16)
text(-1.5,-4.1,['a = ' num2str(exp(b_fin))],'FontSize',16)
text(-1.5,-4.5,['b = ' num2str(m_fin)],'FontSize',16)

end
hold on
plot(log_cos_zenith_reg,log_cs_global_reg,'b-','LineWidth',2.0);
legend('UV irradiance 340','Regression','Location','northwest');
grid on
hold off
graf=(['print -djpeg ',dir_graph,'regression_global_cosz']);
eval(graf);

