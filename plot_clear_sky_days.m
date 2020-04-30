% Plot clear sky days
%
% The following script is for plot clear sky days identify by wavelet 
% transform and normalized methods. For normalized method, clear sky 
% days are define as days with at least 600 one-minute measurements under
% clear sky conditions. In additional, It is generate output file of the 
% clear sky days identify with the normalized method. 
%
% Core developer team:
%
%   * Christian Torres 
%   * Jose Flores
%   * Luis Suarez
%
%%%%%%%%%%  Input parameters: %%%%%%%%%%%
%%%%%%%%%%%    dir work section   %%%%%%%%%%%
%	
%	dir_out            = dir output
%	dir_graph          = dir graphics 
%	dir_in             = dir input
%	filename_in        = file name data sete
%   filename_in1       = file name data fitting wavelet transform method
%   filename_in2       = file name data fitting normalized method
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
%	len_in     = the measurements per day  e.g. [600]
%
%%%%%%%%%%     Output data:   %%%%%%%%%%%
%
%	filename_out       = file output name clear sky days normalized method 

%%  --------------    Plot clear sky days    --------------  %%     

clc
clear all
close all

%%  --------------         dir work          --------------  %%     

dir_out            = ['data/output/'];
dir_graph          = ['graphics/']; 
dir_in             = ['data/input/'];
filename_in        = ['guv_data_all_f.txt'];
filename_in1       = ['cs_data_uv_min_days_met1.txt'];
filename_in2       = ['cs_data_uv_min_met2.txt'];

filename_out       = ['cs_data_uv_min_days_met2.txt'];

%%  --------------  input year and location  --------------  %%     

years_total = [2018,2019,2020];
lon_s       = -75.30;
lat_s       = -12.04;
elv_s       = 3314.0;
zone_s      = -5;

%%  --------  input conditions clear sky days select  ---------  %%     

len_in     = 600;  % one minute measurements 

%%  --------------           read data           --------------  %%     

str_total_dat = [dir_in,filename_in];
var_tot       = load(str_total_dat); 

str_total_dat = [dir_out,filename_in1];
var_tot1       = load(str_total_dat); 

str_total_dat = [dir_out,filename_in2];
var_tot2       = load(str_total_dat); 

%% method 1
n_met1 = length(var_tot1)/1440;

[ah,~,ch]     = unique(var_tot1(:,1:3),'rows');
year_met1  = [accumarray(ch,var_tot1(:,1),[],@nanmean)];
month_met1 = [accumarray(ch,var_tot1(:,2),[],@nanmean)];
day_met1   = [accumarray(ch,var_tot1(:,3),[],@nanmean)];
datenum_met1 = datenum(year_met1,month_met1,day_met1);

%%%%%%%%%% Arrays from data %%%%%%%%%%%%%%
year_input  = var_tot(:,1);
month_input = var_tot(:,2);
day_input   = var_tot(:,3);
hour_input  = var_tot(:,4);
min_input   = var_tot(:,5);
seg_input   = var_tot(:,6);

start_time = int64(round(datenum([year_input(1),month_input(1),...
              day_input(1),0,0,0])*24*60));

end_time   = int64(round(datenum([year_input(end),month_input(end),...
              day_input(end),23,59,0])*24*60));
total_time = (start_time:1:end_time)';    
Vector3 = table([total_time],'VariableNames',{'data_time'});

data_time = int64(round(datenum([var_tot1(:,1),var_tot1(:,2),...
                  var_tot1(:,3),var_tot1(:,4),var_tot1(:,5),...
                  var_tot1(:,6)])*24*60));

Vector4 = table([data_time],[var_tot1]);

Data = outerjoin(Vector3,Vector4,'Type','left');
[~,idx] = unique(Data(:,1));
Data = Data(idx,:);
cs_data_met1 = Data.var_tot1;

%% method 2
% %%%%%%%%%%%%%%%%% Input data must be in column  %%%%%%%%%%%%%%%%%%%%% %%

%%%%%%%%%% Arrays from data %%%%%%%%%%%%%%
year_input  = var_tot2(:,1);
month_input = var_tot2(:,2);
day_input   = var_tot2(:,3);
hour_input  = var_tot2(:,4);
min_input   = var_tot2(:,5);
seg_input   = var_tot2(:,6);
%%%%%%%%%% Irradiance final %%%%%%%%%%%%%
irra_305 = var_tot2(:,7);
irra_320 = var_tot2(:,8);
irra_340 = var_tot2(:,9);
irra_380 = var_tot2(:,10);
dose_erythemal = var_tot2(:,11);

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
      dose_erythemal_day{k,i,j} = dose_erythemal(index_day);

  end
 end
end

%% %%%%%%%%%%%%%%%%%  clear sky conditions days  %%%%%%%%%%%%%%%%%%%%% %%
      
days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};
      
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
dose_guv_day_clear_min  = [];

% loop day

for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i)
      
      lenght_vec = (irra_340_day{k,i,j});   
      lenght_vec = lenght_vec(~isnan(lenght_vec));

      if ( length(lenght_vec) > len_in)

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
         dose_guv_day_clear_min1  = dose_erythemal_day{k,i,j};
         
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
                            dose_guv_day_clear_min1);

            Data = outerjoin(Vector3,Vector4,'Type','left');
            [~,idx] = unique(Data(:,1));
            Data = Data(idx,:);

            [year_day_clear_min1,month_day_clear_min1,day_day_clear_min1,...
             hour_day_clear_min1,min_day_clear_min1,seg_day_clear_min1] = datevec(total_time1);
             irra_340_day_clear_min1  = Data.irra_340_day_clear_min1;
             irra_305_day_clear_min1  = Data.irra_305_day_clear_min1;
             irra_320_day_clear_min1  = Data.irra_320_day_clear_min1;
             irra_380_day_clear_min1  = Data.irra_380_day_clear_min1;
             dose_guv_day_clear_min1  = Data.dose_guv_day_clear_min1;

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
         dose_guv_day_clear_min  = [dose_guv_day_clear_min;dose_guv_day_clear_min1];

      end
  end
 end
end

cs_total_days = [year_day_clear_min,month_day_clear_min,day_day_clear_min,...
                 hour_day_clear_min,min_day_clear_min,seg_day_clear_min,...
                 irra_305_day_clear_min,irra_320_day_clear_min,...
                 irra_340_day_clear_min,irra_380_day_clear_min,...
                 dose_guv_day_clear_min];

%% save data clear sky days

str_total_out = [dir_out,filename_out];
dlmwrite(str_total_out,cs_total_days,'delimiter',' ','precision','%.3f');

n_met2 = length(cs_total_days)/1440;

[ah,~,ch]     = unique(cs_total_days(:,1:3),'rows');
year_met2  = [accumarray(ch,cs_total_days(:,1),[],@nanmean)];
month_met2 = [accumarray(ch,cs_total_days(:,2),[],@nanmean)];
day_met2   = [accumarray(ch,cs_total_days(:,3),[],@nanmean)];
datenum_met2 = datenum(year_met2,month_met2,day_met2);

%% Coincide days 

n_coin_days = 0;
for i = 1:length(datenum_met1)
    for j = 1:length(datenum_met2)
        if datenum_met1(i) == datenum_met2(j)
           n_coin_days = n_coin_days+1; 
        end
    end
end
%% complete lenght method 2 

%%%%%%%%%% Arrays from data %%%%%%%%%%%%%%
year_input  = var_tot(:,1);
month_input = var_tot(:,2);
day_input   = var_tot(:,3);
hour_input  = var_tot(:,4);
min_input   = var_tot(:,5);
seg_input   = var_tot(:,6);

start_time = int64(round(datenum([year_input(1),month_input(1),...
              day_input(1),0,0,0])*24*60));

end_time   = int64(round(datenum([year_input(end),month_input(end),...
              day_input(end),23,59,0])*24*60));
total_time = (start_time:1:end_time)';    
Vector3 = table([total_time],'VariableNames',{'data_time'});

data_time = int64(round(datenum([year_day_clear_min,month_day_clear_min,...
                  day_day_clear_min,hour_day_clear_min,min_day_clear_min,...
                  seg_day_clear_min])*24*60));
Vector4 = table([data_time],[cs_total_days]);

Data = outerjoin(Vector3,Vector4,'Type','left');
[~,idx] = unique(Data(:,1));
Data = Data(idx,:);
cs_data_met2 = Data.cs_total_days;

%% datetime plot
start_time = (datetime([var_tot(1,1),var_tot(1,2),...
              var_tot(1,3),0,0,0]));

end_time   = (datetime([var_tot(end,1),var_tot(end,2),...
              var_tot(end,3),23,59,0]));
          
total_time = (start_time:minutes(1):end_time)';
date_vec = datevec(total_time);
date_aws  = datenum(date_vec(:,1:6));
date_aws1 = datenum(date_vec(:,1:3));
hour_dec  = date_vec(:,4)+(date_vec(:,5)/60);
A = datetime(var_tot(1,1),01,01);
B = datetime(2019,12,31);
C = datenum(linspace(A,B,12));

cs_var_a_24_1 = reshape(cs_data_met1(:,11),[1440,length(cs_data_met1(:,11))/1440]);
cs_var_a_24_2 = reshape(cs_data_met2(:,11),[1440,length(cs_data_met2(:,11))/1440]);

cs_hour_24       = reshape(hour_dec,[1440,length(hour_dec)/1440]);
cs_date_aws_24   = reshape(date_aws,[1440,length(date_aws)/1440]);

%% plot days select

figure1 = figure('Color',[1 1 1], 'visible','off','DefaultAxesPosition', [0.07, 0.15, 0.88, 0.8]);
x0 = 10; y0 = 10;
width  = 580;
height = 380;
set(gcf,'PaperPositionMode','auto');
set(figure1,'units','points','position',[x0,y0,width,height]);

subplot(2,1,1)
h1 = pcolor(cs_date_aws_24,cs_hour_24,cs_var_a_24_1);
colormap jet
shading interp
set(h1,'LineStyle','none')
colorbar
hcb = colorbar;
ylabel(hcb, 'UV index','FontSize', 16)
val_cot = [0:4:24];
set(hcb,'YTick',val_cot,'LineWidth', 0.5, 'FontSize', 16)
caxis([0,24])
set(gca,'XTick',C)
datetick('x','dd-mm-yy','keepticks')
set(gca,'YTick',(0:4:24),'FontSize', 16)
set(gca, 'LineWidth', 0.5, 'FontSize', 16)
set(gca,'XTickLabelRotation',45)
text(datenum(2018,01,20,0,0,0),20,'(a)','FontSize', 18)
text(datenum(2019,09,01,0,0,0),20,['N = ',num2str(n_met1)],'FontSize', 18)
text(datenum(2019,07,01,0,0,0),3,['N coincide = ',num2str(n_coin_days)],'FontSize', 14)
xlim([C(1) C(end)])
ylim([0 24])
ylabel('Hour','FontSize', 16)
grid
set(gca,'layer','top')
box on
subplot(2,1,2)
h1 = pcolor(cs_date_aws_24,cs_hour_24,cs_var_a_24_2);
colormap jet
shading interp
set(h1,'LineStyle','none')
colorbar
hcb = colorbar;
ylabel(hcb, 'UV index','FontSize', 16)
val_cot = [0:4:24];
set(hcb,'YTick',val_cot,'LineWidth', 0.5, 'FontSize', 16)
caxis([0,24])
set(gca,'XTick',C)
datetick('x','dd-mm-yy','keepticks')
set(gca,'YTick',(0:4:24),'FontSize', 16)
set(gca, 'LineWidth', 0.5, 'FontSize', 16)
set(gca,'XTickLabelRotation',45)
text(datenum(2018,01,20,0,0,0),20,'(b)','FontSize', 18)
text(datenum(2019,09,01,0,0,0),20,['N = ',num2str(n_met2)],'FontSize', 18)
xlim([C(1) C(end)])
ylim([0 24])
ylabel('Hour','FontSize', 16)
grid
set(gca,'layer','top')
box on
% save graph in format png
graf=(['print -dpng ',dir_graph,'select_days_mets.png']);
eval(graf);
