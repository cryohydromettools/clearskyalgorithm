%%  --------------  claer sky day algorithm  --------------  %%     

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
year_input  = var_tot(:,1);
month_input = var_tot(:,2);
day_input   = var_tot(:,3);
hour_input  = var_tot(:,4);
min_input   = var_tot(:,5);
seg_input   = var_tot(:,6);
seg_input   = linspace(0,0,length(seg_input))';
%%%%%%%%%% Irradiance final %%%%%%%%%%%%%
irra_305 = var_tot(:,7)/100;
irra_320 = var_tot(:,8)/100;
irra_340 = var_tot(:,9)/100;
irra_380 = var_tot(:,10)/100;
%% repare time serie

t1      = int64(round(datenum([year_input(1),month_input(1),day_input(1),0,0,0])*24*60));
t2      = int64(round(datenum([year_input(end),month_input(end),day_input(end),23,59,0])*24*60));
t_total = [t1:1:t2]'; 
t_dat  = int64(round(datenum([year_input,month_input,day_input,hour_input,min_input,seg_input])*24*60));
Vector3 = table([t_total],'VariableNames',{'t_dat'});
Vector4 = table([t_dat],[var_tot]);
Data_sel = outerjoin(Vector3,Vector4,'Type','left');
[~,idx] = unique(Data_sel(:,1));
Data_sel = Data_sel(idx,:);
Data_sel1 = Data_sel.var_tot;

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
%% %%%%%%%%%%%%%%%%% Input data must be in column  %%%%%%%%%%%%%%%%%%%%% %%
decimalyear = datenum([year_input,month_input,day_input,...
                       hour_input,min_input,seg_input]);
hour_cont = hour_input' + min_input'./60.0 + seg_input'./3600;   

days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};
for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i)
       
   index_day = find(year_input == years_total(k) & month_input == i & day_input == j);
   
   nindex_day(j) = length(index_day);
   
      zenith_day{k,i,j} = zenith_input(index_day);   
      decimalyear_day{k,i,j} = decimalyear(index_day);
      year_day{k,i,j}  = year_input(index_day);
      month_day{k,i,j} = month_input(index_day);
      day_day{k,i,j}   = day_input(index_day);
      hour_day{k,i,j}  = hour_input(index_day);
      min_day{k,i,j}   = min_input(index_day);
      seg_day{k,i,j}   = seg_input(index_day);
      hour_cont_day{k,i,j} = hour_cont(index_day);
      irra_340_day{k,i,j}  = irra_340(index_day);
      irra_305_day{k,i,j}  = irra_305(index_day);
      irra_320_day{k,i,j}  = irra_320(index_day);
      irra_380_day{k,i,j}  = irra_380(index_day);
  end
 end
end

%% %%%%%%%%%%%%%%%%%  clear sky conditions days  %%%%%%%%%%%%%%%%%%%%% %%
rsquare_in = 0.975;
rmse_in    = 0.05;
len_in     = 650;
bcoef      = 1.43;

year_day_clear_min  = [];
month_day_clear_min = [];
day_day_clear_min   = [];
hour_day_clear_min  = [];
min_day_clear_min   = [];
seg_day_clear_min   = [];
irra_340_day_clear_min  = [];
irra_305_day_clear_min  = [];
irra_320_day_clear_min  = [];
irra_380_day_clear_min  = [];
zenith_day_clear_min     = [];
      
days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};
      
% loop day

for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i)

      if ( length(irra_340_day{k,i,j}) > 650)

%k = 1;
%i = 5;
%j = 26;
      %%%% Set global irradiance as input %%%%     
         Io = irra_340_day{k,i,j};
         zen_ang   = zenith_day{k,i,j};
         hour_cont = hour_cont_day{k,i,j};
         N_tot = length(Io);

      %%% Initialize vectors %%%  
         Io_f = zeros(1,N_tot);
         hour_f = zeros(1,N_tot);

         for yi=1:N_tot

           if (zen_ang(yi) < 88.0)
             Io_f(yi)  = Io(yi); 
             hour_f(yi)= hour_cont(yi);
           else
             Io_f(yi) = NaN;
             hour_f(yi)= NaN;
           end

         end

         %----------  Remove NAN from vectors ----------%
         dat_fit = [hour_f',Io_f'];
         dat_fit(any(isnan(dat_fit), 2), :) = [];
         hour_f  = dat_fit(:,1)';
         Io_f    = dat_fit(:,2)';         

         % Fit to a gaussian curve
         [curve2,gof2] = fit(hour_f',Io_f','gauss1');

             %------ Condition to select clear sky days -------%

          if ( gof2.rsquare >= rsquare_in && gof2.rmse < rmse_in  && length(Io_f) > len_in )

             irra_340_clear{k,i,j}  = irra_340_day{k,i,j};
             irra_305_clear{k,i,j}  = irra_305_day{k,i,j};
             irra_320_clear{k,i,j}  = irra_320_day{k,i,j};
             irra_380_clear{k,i,j}  = irra_380_day{k,i,j};
             year_clear{k,i,j}      = year_day{k,i,j}; 
             month_clear{k,i,j}     = month_day{k,i,j}; 
             day_clear{k,i,j}       = day_day{k,i,j}; 
             hour_clear{k,i,j}      = hour_day{k,i,j}; 
             min_clear{k,i,j}       = min_day{k,i,j};
             seg_clear{k,i,j}       = seg_day{k,i,j};
             name=['Clear sky day',':',num2str(years_total(k)),'-',num2str(i),'-',num2str(j)];
             disp(name);

          %%%% START WAVELETS ALGORITHM TO SELECT CLEAR SKY DAYS  %%%%%%%%%%%%%

                 if ( length(irra_340_day{k,i,j}) > 650 )

                  %---- Level of decomposition --------%
                  des_lev = 3;

                  [C,L] = wavedec(Io_f,des_lev,'dmey');
                  N_total=L(des_lev+2);

                   A1 = wrcoef('a',C,L,'dmey',1);
                   A2 = wrcoef('a',C,L,'dmey',2);
                   A3 = wrcoef('a',C,L,'dmey',3);
                   %--------------------------------
                   D1 = wrcoef('d',C,L,'dmey',1);
                   D2 = wrcoef('d',C,L,'dmey',2);
                   D3 = wrcoef('d',C,L,'dmey',3);

                   %%%%%%% Compute the initial standard deviation %%%%%%%%%%%%

                   std_wo = nanstd(Io_f-A3);
                   thres = 10^-6;
                   coef_eval = 1.0;
                   n_cont=0.0;
%%
                   while (coef_eval > thres)
%%
                   %---- Keep the value of old std---%
                    std_wo_old = std_wo;
                    cont_sig1 = 0.0;
                    cont_sig2 = 0.0;
                    cont_sig3 = 0.0;

                    cont_tot = 0.0;

                    M_f1  = zeros(1,N_total);
                    M_f2  = zeros(1,N_total);
                    M_f3  = zeros(1,N_total);
                    I_int = zeros(1,N_total);

                    %%%%%%%% Calculation of multiresolution support %%%%%%%%%%
                     for yi=1:N_total

                       if ( abs(D1(yi)) > 3.5*std_wo ) 
                           M_f1(yi) = 1.0; 
                           cont_sig1 = cont_sig1 + 1;
                       else
                           M_f1(yi) = 0.0;
                       end

                       if ( abs(D2(yi)) > 3.5*std_wo )
                           M_f2(yi) = 1.0;
                           cont_sig2 = cont_sig2 + 1;
                       else
                           M_f2(yi) = 0.0;
                       end

                       if ( abs(D3(yi)) > 3.5*std_wo )
                           M_f3(yi) = 1.0;
                           cont_sig3 = cont_sig3 + 1;
                       else
                           M_f3(yi) = 0.0;
                       end


                       if ( M_f1(yi) == 0.0 && M_f2(yi) == 0.0  && M_f3(yi) == 0.0 )
                          I_int(yi) = Io_f(yi);
                          cont_tot = cont_tot + 1;
                       else
                          I_int(yi) = NaN;
                       end

                     end

%                     A31 = A3';
                     I_final = I_int - A3;

                     std_wo = nanstd(I_final);
                     coef_eval = abs(std_wo-std_wo_old)/std_wo;

                     n_cont = n_cont + 1;

                   end

                   cont_clear = 0.0;
                   for yi=1:N_total
                      if (abs(D3(yi)) < 3.5*std_wo)
                        cont_clear = cont_clear + 1; 
                      end
                   end


                  figure1 = figure('Color',[1 1 1], 'visible','off');
                  x0 = 10; y0 = 10;
                  width  = 250;
                  height = 240;
                  set(gcf,'PaperPositionMode','auto');
                  set(figure1,'units','points','position',[x0,y0,width,height]);
                  plot(hour_f,Io_f,'k-','LineWidth',1.5);
                  axis([5 19 0 1.2]);
                  set(gca,'XTick',(5:2:19),'FontSize', 12);
                  set(gca,'YTick',(0:0.20:1.2),'FontSize', 12); 
                  grid on
                  hold on
                  plot(hour_f,A1,'b-','LineWidth',1.0);
                  plot(hour_f,A2,'r-','LineWidth',1.0);
                  plot(hour_f,A3,'g-','LineWidth',0.5);
                  hold off
                  ylabel('340 Irradiance (W m^{-2} nm^{-1})','FontSize', 12)
                  xlabel('Local time','FontSize', 12)
                  graf=(['print -dpng -r300 ',dir_graph,'irra_340','_',...
                                         num2str(years_total(k)),'_',...
                                         num2str(i),'_',num2str(j)]);
                  eval(graf);

                %------ Final Condition to select clear sky days -------%

                   if ( 3.5*std_wo > max(abs(D3)) )
                     irra_340_clear_final{k,i,j} = irra_340_clear{k,i,j}; 
                     name=['Clear sky day FINAL',':',num2str(i),'-',num2str(j)];
                     disp(name);

                   else
                     irra_340_clear_final{k,i,j} = NaN; 

                   end

                %-------- Fill empty values with NaN -------------%      
                   ix=cellfun(@isempty,irra_340_clear);
                   irra_340_clear(ix)={NaN};

                   ix=cellfun(@isempty,irra_340_clear_final);
                   irra_340_clear_final(ix)={NaN};

                   ix=cellfun(@isempty,year_clear);
                   year_clear(ix)={NaN};

                   ix=cellfun(@isempty,month_clear);
                   month_clear(ix)={NaN};

                   ix=cellfun(@isempty,day_clear);
                   day_clear(ix)={NaN};

                   ix=cellfun(@isempty,hour_clear);
                   hour_clear(ix)={NaN};

                   ix=cellfun(@isempty,min_clear);
                   min_clear(ix)={NaN};

                   ix=cellfun(@isempty,seg_clear);
                   seg_clear(ix)={NaN};

                 %------ Save data one minutes -------%     

                     year_day_clear_min1  = year_day{k,i,j};
                     month_day_clear_min1 = month_day{k,i,j};
                     day_day_clear_min1   = day_day{k,i,j};
                     hour_day_clear_min1  = hour_day{k,i,j};
                     min_day_clear_min1   = min_day{k,i,j};
                     seg_day_clear_min1   = seg_day{k,i,j};
                     irra_340_day_clear_min1  = irra_340_day{k,i,j};
                     irra_305_day_clear_min1  = irra_305_day{k,i,j};
                     irra_320_day_clear_min1  = irra_320_day{k,i,j};
                     irra_380_day_clear_min1  = irra_380_day{k,i,j};
                     zenith_day_clear_min1     = zenith_day{k,i,j};   

                    if length(year_day_clear_min1)~= 1440

                        start_time = datenum([year_day_clear_min1(1),month_day_clear_min1(1),...
                                      day_day_clear_min1(1),0,0,0]);

                        end_time   = datenum([year_day_clear_min1(1),month_day_clear_min1(1),...
                                      day_day_clear_min1(1),23,59,0]);

                        total_time1 = linspace(start_time,end_time,1440)';    

                        start_time = int64(round(datenum([year_day_clear_min1(1),month_day_clear_min1(1),...
                                      day_day_clear_min1(1),0,0,0])*24*60));

                        end_time   = int64(round(datenum([year_day_clear_min1(1),month_day_clear_min1(1),...
                                      day_day_clear_min1(1),23,59,0])*24*60));

                        total_time = (start_time:1:end_time)';    

                        data_time  = int64(round(datenum([year_day_clear_min1,month_day_clear_min1,...
                                      day_day_clear_min1,hour_day_clear_min1,min_day_clear_min1,...
                                          seg_day_clear_min1])*24*60));

                        Vector3 = table([total_time],'VariableNames',{'data_time'});

                        Vector4 = table([data_time],[irra_340_day_clear_min1],...
                                        [irra_305_day_clear_min1],...
                                        [irra_320_day_clear_min1],...
                                        [irra_380_day_clear_min1],...
                                        [zenith_day_clear_min1]);

                        Data = outerjoin(Vector3,Vector4,'Type','left');
                        [~,idx] = unique(Data(:,1));
                        Data = Data(idx,:);

                        [year_day_clear_min1,month_day_clear_min1,day_day_clear_min1,...
                         hour_day_clear_min1,min_day_clear_min1,seg_day_clear_min1] = datevec(total_time1);
                         irra_340_day_clear_min1  = Data.irra_340_day_clear_min1;
                         irra_305_day_clear_min1  = Data.irra_305_day_clear_min1;
                         irra_320_day_clear_min1  = Data.irra_320_day_clear_min1;
                         irra_380_day_clear_min1  = Data.irra_380_day_clear_min1;
                         zenith_day_clear_min1     = Data.zenith_day_clear_min1;

                    end

                     year_day_clear_min  = [year_day_clear_min;year_day_clear_min1];
                     month_day_clear_min = [month_day_clear_min;month_day_clear_min1];
                     day_day_clear_min   = [day_day_clear_min;day_day_clear_min1];
                     hour_day_clear_min  = [hour_day_clear_min;hour_day_clear_min1];
                     min_day_clear_min   = [min_day_clear_min;min_day_clear_min1];
                     seg_day_clear_min   = [seg_day_clear_min;seg_day_clear_min1];
                     irra_340_day_clear_min  = [irra_340_day_clear_min;irra_340_day_clear_min1];
                     irra_305_day_clear_min  = [irra_305_day_clear_min;irra_305_day_clear_min1];
                     irra_320_day_clear_min  = [irra_320_day_clear_min;irra_320_day_clear_min1];
                     irra_380_day_clear_min  = [irra_380_day_clear_min;irra_380_day_clear_min1];
                     zenith_day_clear_min     = [zenith_day_clear_min;zenith_day_clear_min1];   

                 end
          end
      end
  end
 end
end
%% save data days clear sky

data_clear_select_min = [year_day_clear_min,month_day_clear_min,...
                         day_day_clear_min,hour_day_clear_min,...
                         min_day_clear_min,seg_day_clear_min,...
                         irra_305_day_clear_min,irra_320_day_clear_min,...
                         irra_340_day_clear_min,...
                         irra_380_day_clear_min,zenith_day_clear_min];

str_total_out = [dir_out,filename_out];
dlmwrite(str_total_out,data_clear_select_min,'delimiter',' ','precision','%.3f');

%% %%%%%%%%%%% calculate zenith angle cs days %%%%%%%%%%%%%%%%%%% %%
for i = 1:length(seg_day_clear_min);
%location for site
location.longitude = lon_s; 
location.latitude  = lat_s; 
location.altitude  = elv_s;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time.year  = year_day_clear_min(i);
time.month = month_day_clear_min(i);
time.day   = day_day_clear_min(i);  
time.hour  = hour_day_clear_min(i);
time.min   = min_day_clear_min(i);
time.sec   = seg_day_clear_min(i);
time.UTC   = zone_s; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sun = sun_position(time, location);
zenith_input_cs1(i) = sun.zenith;
end
zenith_input_cs = zenith_input_cs1';

%% %%%%%%%%%  calculate extraterrestrial irradiance cs days %%%%%%%%%%%% %%

for k=1:length(year_day_clear_min)

dt_local = datetime(year_day_clear_min(k),month_day_clear_min(k),...
                    day_day_clear_min(k),hour_day_clear_min(k),...
                    min_day_clear_min(k),seg_day_clear_min(k),...
                    'TimeZone','America/Lima');

dt_local.TimeZone  = 'UTC';

[year_utc,month_utc,day_utc,hour_utc,min_utc,seg_utc] = datevec(datenum(dt_local));

[year_r,month_r,day_r,hour_r,min_r,log_bissexto,n_day_r,n_days_year,...
year_rad] = year_02(year_utc,month_utc,day_utc,hour_utc,min_utc,seg_utc);

n_day_r = ( year_r - floor(year_r)) * n_days_year;

[decl_rad(k),sunrise_h(k),sunset_h(k),day_dur_h(k),ecce(k),extra_uv_cs1(k)] =...
    extra_uv_rad(n_day_r,lon_s,lat_s,zenith_input_cs(k));

end

%% %%%%%%%%%%%%%%%%%           clear index         %%%%%%%%%%%%%%%%%%%%% %%
for i=1:length(zenith_input_cs)
  if ( zenith_input_cs(i) <= 80.0)
      cs_index(i) = irra_340_day_clear_min(i)/extra_uv_cs1(i);
  else 
      cs_index(i) = NaN;
  end
end
cs_in_day_min = nanmean(reshape(cs_index,[1440,length(cs_index)/1440]),2);

%% %%%%%%%%% calculate extraterrestrial irradiance all days %%%%%%%%%%%% %%

for k=1:length(month_input)

dt_local = datetime(year_input(k),month_input(k),...
                    day_input(k),hour_input(k),...
                    min_input(k),seg_input(k),...
                    'TimeZone','America/Lima');

dt_local.TimeZone  = 'UTC';

[year_utc,month_utc,day_utc,hour_utc,min_utc,seg_utc] = datevec(datenum(dt_local));

[year_r,month_r,day_r,hour_r,min_r,log_bissexto,n_day_r,n_days_year,...
year_rad] = year_02(year_utc,month_utc,day_utc,hour_utc,min_utc,seg_utc);

n_day_r = ( year_r - floor(year_r)) * n_days_year;

[decl_rad(k),sunrise_h(k),sunset_h(k),day_dur_h(k),ecce(k),extra_uv_all1(k)] =...
    extra_uv_rad(n_day_r,lon_s,lat_s,zenith_input(k));

end
extra_uv_all = extra_uv_all1';

%%

t1 = datetime('2018-04-01 00:00:00','Format','yyyy-MM-dd HH:mm:ss');
t2 = datetime('2020-01-31 23:59:00','Format','yyyy-MM-dd HH:mm:ss');
dt_local = (t1:minutes(1):t2)';

%%
dt_local1   = datetime(year_input,month_input,day_input,...
                       hour_input,min_input,seg_input,...
                       'Format','yyyy-MM-dd HH:mm:ss'); 

%%
Vector3 = table([dt_local],'VariableNames',{'dt_local1'});
Vector4 = table([dt_local1],[irra_340],[extra_uv_all],[zenith_input]);
Data = outerjoin(Vector3,Vector4,'Type','left');
[~,idx] = unique(Data(:,1));
Data = Data(idx,:);
%%
extra_uv_all1 = Data.extra_uv_all;
zenith_input1 = Data.zenith_input;
x1 = 1;
x2 = 1440;
surf_uv_all = [];
cs_in_day_min = cs_index(1:1440)';
for i = 1:(length(extra_uv_all1)/1440)
    extra_uv_all_d = extra_uv_all1(x1:x2);
    surf_uv_all_d  = extra_uv_all_d .* cs_in_day_min;
    x1 = x2 + 1;
    x2 = x2 + 1440;
surf_uv_all = [surf_uv_all;surf_uv_all_d];
end

%%
days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};
for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i)
       
   index_day = find(year_input == years_total(k) & month_input == i & day_input == j);
   
   nindex_day(j) = length(index_day);
   
      extra_uv_all_day{k,i,j}  = extra_uv_all(index_day);
  end
 end
end

%% %%%%%%%%%%%%  calculate surface irradiance from ext  %%%%%%%%%%%%%%%% %%

uv_extra_surf_all  = [];
days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};

for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i)    

%k = 1;
%i = 4;
%j = 18;

      extra_uv_all_day1  = extra_uv_all_day{k,i,j};
      zen_ang   = zenith_day{k,i,j};
      hour_cont = hour_cont_day{k,i,j}';
     
      t1 = datetime('00:00:00','Format','HH:mm:ss');
      t2 = datetime('23:59:00','Format','HH:mm:ss');
      hour_cont1 = t1:minutes(1):t2;
      [hour_input1,min_input1,seg_input1] = hms(hour_cont1);
      hour_cont1 = hour_input1' + min_input1'./60.0 + seg_input1'./3600;

      Vector3 = table([hour_cont],'VariableNames',{'hour_cont1'});

        if length(hour_cont) > 0
              Vector4 = table([hour_cont1],[cs_in_day_min]);

              Data = outerjoin(Vector3,Vector4,'Type','left');
              [~,idx] = unique(Data(:,1));
              Data = Data(idx,:);
              cs_in_day_min1 = Data.cs_in_day_min;
%              cs_in_day_min1 = cs_index(1:1440);

              for ii = 1:length(cs_in_day_min1)
                if ( zen_ang(ii) <= 80.0)
                  uv_extra_surf(ii) = -extra_uv_all_day1(ii)*cs_in_day_min1(ii);
                else 
                  uv_extra_surf(ii) = NaN;
                end
              end
           uv_extra_surf_all  = [uv_extra_surf_all;uv_extra_surf'];
        end
      
   end
 end
end

%% %%%%%%%%%%%%%%%%%  calculate normal irradiance  %%%%%%%%%%%%%%%%%%%%% %%

for i=1:length(zenith_day_clear_min)
  if ( zenith_day_clear_min(i) <= 80.0)
      irra_340_normal(i) = irra_340_day_clear_min(i)/(cos(pi*zenith_day_clear_min(i)/180)^bcoef);
  else 
      irra_340_normal(i) = NaN;
  end
end
%% %%%%%%%%%%%%%%%%%       finding thresholds      %%%%%%%%%%%%%%%%%%%%% %%

hour_cont =  hour_day_clear_min + min_day_clear_min./60.0 + seg_day_clear_min./3600;irra_340_normal_mean = nanmean(reshape(irra_340_normal,[1440,length(irra_340_normal)/1440]),2);

irra_340_day_clear_mean = nanmean(reshape(irra_340_day_clear_min,[1440,length(irra_340_day_clear_min)/1440]),2);
zenith_day_clear_min_mean = nanmean(reshape(zenith_day_clear_min,[1440,length(zenith_day_clear_min)/1440]),2);

threshold_max = nanmax(irra_340_normal_mean);
threshold_min = nanmin(irra_340_normal_mean);
threshold_min_78 = threshold_min - 0.05*threshold_min;
threshold_max_v  = linspace(threshold_max,threshold_max,1440);
threshold_min_v  = linspace(threshold_min,threshold_min,1440);

for i=1:length(zenith_day_clear_min_mean)
  if ( zenith_day_clear_min_mean(i) <= 78.5)
      threshold_min_v(i) = threshold_min;
  else 
      threshold_min_v(i) = threshold_min_78;
  end
end

figure1 = figure('Color',[1 1 1], 'visible','off');
x0 = 10; y0 = 10;
width  = 250;
height = 240;
set(gcf,'PaperPositionMode','auto');
set(figure1,'units','points','position',[x0,y0,width,height]);
hold on
plot(hour_cont(1:1440),irra_340_day_clear_mean,'b-','LineWidth',1.0);
plot(hour_cont(1:1440),irra_340_normal_mean,'r-','LineWidth',1.0);
plot(hour_cont(1:1440),threshold_max_v,'k-','LineWidth',1.0);
plot(hour_cont(1:1440),threshold_min_v,'k-','LineWidth',1.0);
hold off
axis([0 23 0 1.2]);
set(gca,'XTick',(0:3:23),'FontSize', 12);
set(gca,'YTick',(0:0.20:1.2),'FontSize', 12); 
grid on
ylabel('340 Irradiance (W m^{-2} nm^{-1})','FontSize', 12)
xlabel('Local time','FontSize', 12)
box on
graf=(['print -dpng -r300 ',dir_graph,'irra_clear_sky_mean']);
eval(graf);

%% %%%%%%%%%%%%%%%%%  save thresholds  %%%%%%%%%%%%%%%%%%%%% %%

firt_thresholds = [threshold_max;threshold_min;threshold_min_78];
str_total_out = [dir_out,filename_out_thres];
dlmwrite(str_total_out,firt_thresholds,'delimiter',' ','precision','%.3f');
