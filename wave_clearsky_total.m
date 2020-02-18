clc
clear all
close all

format long g;
%--------------------------------
dir_out     = 'output/';
titulo_guv  = 'guv_total_2005';
dir_graph   = 'graphics/'; 

vars_1  = load('input/data_03_04_2018_17_04_2018.txt');
vars_2  = load('input/data_18_04_2018_01_31_2020.txt');

var_tot = [vars_1;vars_2];
%%%%%%%% Arrays from data %%%%%%%%%%%%%%
year_input  = var_tot(:,1);
month_input = var_tot(:,2);
day_input   = var_tot(:,3);
hour_input  = var_tot(:,4);
min_input   = var_tot(:,5);
seg_input   = var_tot(:,6);
%%%%%%%%%% Irradiances final %%%%%%%%%%%%%
irra_305 = var_tot(:,7);
irra_320 = var_tot(:,8);
irra_340 = var_tot(:,10);
irra_380 = var_tot(:,11);
%% %%%%%%%%%%% calculate zenith angle %%%%%%%%%%%%%%%%%%%%%
for i = 1:length(year_input);
%location for huancayo
location.longitude = -75.30; 
location.latitude = -12.04; 
location.altitude = 3314.0;
%cal = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time.year  = year_input(i);
time.month = month_input(i);
time.day   = day_input(i);  
time.hour  = hour_input(i);
time.min   = min_input(i);
time.sec   = seg_input(i);
time.UTC   = -5; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sun = sun_position(time, location);
zenith_input(i) = sun.zenith;
end

%% %%%%%% Input data must be in column  %%%%%%%%%%%%%%%%%%%%%%%
decimalyear = datenum([year_input,month_input,day_input,...
                       hour_input,min_input,seg_input]);
hour_cont = hour_input' + min_input'./60.0 + seg_input'./3600;   

years_total = [2018,2019,2020];
days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};

for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i) %day
       
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
      %%%%%
      irra_305_day{k,i,j}  = irra_305(index_day);
      irra_320_day{k,i,j}  = irra_320(index_day);
      irra_340_day{k,i,j}  = irra_340(index_day);
      irra_380_day{k,i,j}  = irra_380(index_day);
      %%%
  
  end
 end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%

year_day_clear_min  = [];
month_day_clear_min = [];
day_day_clear_min   = [];
hour_day_clear_min  = [];
min_day_clear_min   = [];
seg_day_clear_min   = [];
global_SW_day_clear_min  = [];
direct_SW_day_clear_min  = [];
diffus_SW_day_clear_min  = [];
reflec_SW_day_clear_min  = [];
emited_LW_day_clear_min  = [];
incide_LW_day_clear_min  = [];
zenith_day_clear_min     = [];
      
years_total = [2018,2019,2020];
days_month = [31,29,31,30,31,30,31,31,30,31,30,31];
months = {'January','February','March','April','May','June',...
          'July','August','September','October','November',...
          'December'};
%%

for k=1:length(years_total)
                   
 for i=1:length(days_month)

  for j=1:days_month(i) %day
      
      if ( ~isnan(irra_340_day{k,i,j}) ) 
 
  %%%% Set global irradiance as input      
     Io = irra_340_day{k,i,j};
     zen_ang   = zenith_day{k,i,j};
     hour_cont = hour_cont_day{k,i,j};
     N_tot = length(Io);
  
  %%% Initialize vectors   
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
     
     %----------  Remove NAN from vectors ----------
     Io_f(isnan(Io_f))     = [];
     hour_f(isnan(hour_f)) = [];
     
     % Fit to a gaussian curve
     [curve2,gof2] = fit(hour_f',Io_f','gauss1');
     
         %------ Condition to select clear sky days -------
    
      if ( gof2.rsquare >= 0.98 && gof2.rmse < 3.8  && length(Io_f) > 650 )
         irra_340_clear{k,i,j}  = irra_340_day{k,i,j}; 
         year_clear{k,i,j}      = year_day{k,i,j}; 
         month_clear{k,i,j}     = month_day{k,i,j}; 
         day_clear{k,i,j}       = day_day{k,i,j}; 
         hour_clear{k,i,j}      = hour_day{k,i,j}; 
         min_clear{k,i,j}       = min_day{k,i,j};
         seg_clear{k,i,j}       = seg_day{k,i,j};
         name=['Clear sky day',':',num2str(years_total(k)),'-',num2str(i),'-',num2str(j)];
         disp(name);
      
      %%%% START WAVELETS ALGORITHM TO SELECT CLEAR SKY DAYS  %%%%%%%%%%%%%
      
             if ( ~isnan(irra_340_clear{k,i,j}) )

                   %---- Level of decomposition --------
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

               %%%%%%% Compute the initial standard deviation %%%%%%%%%%%%%%

               std_wo = nanstd(Io_f-A3);
               thres = 10^-6;
               coef_eval = 1.0;
               n_cont=0.0;

               while (coef_eval > thres)

               %---- Keep the value of old std---
                std_wo_old = std_wo;
                cont_sig1 = 0.0;
                cont_sig2 = 0.0;
                cont_sig3 = 0.0;

                cont_tot = 0.0;

                M_f1  = zeros(1,N_total);
                M_f2  = zeros(1,N_total);
                M_f3  = zeros(1,N_total);
                I_int = zeros(1,N_total);

                %%%%%%%% Calculation of multiresolution support %%%%%%%%%%%%%%
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

              figure('visible','off')
              plot(hour_f,abs(D3),'ro');
              axis([5 19 0 6*std_wo]);
              set(gca,'XTick',(5:2:19),'FontSize', 12);
              set(gca,'YTick',(0:std_wo:6*std_wo),'FontSize', 12); 
              grid on
              hold on
              refline(0,3.5*std_wo);
              hold off
              graf=(['print -djpeg ',dir_graph,'detail_std','_',...
                                     num2str(years_total(k)),'_',...
                                     num2str(i),'_',num2str(j)]);
              eval(graf);

              figure('visible','off')
              plot(hour_f,Io_f,'k-','LineWidth',1.5);
              axis([5 19 0 200]);
              set(gca,'XTick',(5:1:19),'FontSize', 12);
              set(gca,'YTick',(0:20:200),'FontSize', 12); 
              grid on
              hold on
              plot(hour_f,A1,'b-','LineWidth',1.0);
              plot(hour_f,A2,'r-','LineWidth',1.0);
              plot(hour_f,A3,'g-','LineWidth',0.5);
              hold off
              graf=(['print -djpeg ',dir_graph,'globalSW','_',...
                                     num2str(years_total(k)),'_',...
                                     num2str(i),'_',num2str(j)]);
              eval(graf);

            %------ Final Condition to select clear sky days -------

               if ( 3.5*std_wo > max(abs(D3)) )
                 irra_340_clear_final{k,i,j} = irra_340_clear{k,i,j}; 
                 name=['Clear sky day FINAL',':',num2str(i),'-',num2str(j)];
                 disp(name);

               else
                 irra_340_clear_final{k,i,j} = NaN; 
            %      name=['Non clear sky day',':',num2str(i),'-',num2str(j)];
            %     disp(name);
               end

            %-------- Fill empty values with NaN -------------      
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
             end
        end
      end
  end
 end
end
%%
       %-------------------------------------------------%   
         %------ Save data one minutes -------%     

     year_day_clear_min1  = year_day{k,i,j};
     month_day_clear_min1 = month_day{k,i,j};
     day_day_clear_min1   = day_day{k,i,j};
     hour_day_clear_min1  = hour_day{k,i,j};
     min_day_clear_min1   = min_day{k,i,j};
     seg_day_clear_min1   = seg_day{k,i,j};
     global_SW_day_clear_min1  = global_SW_day{k,i,j};
     direct_SW_day_clear_min1  = direct_SW_day{k,i,j};
     diffus_SW_day_clear_min1  = diffus_SW_day{k,i,j};
     reflec_SW_day_clear_min1  = reflec_SW_day{k,i,j};
     emited_LW_day_clear_min1  = emited_LW_day{k,i,j};
     incide_LW_day_clear_min1  = incide_LW_day{k,i,j};
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

        Vector4 = table([data_time],[global_SW_day_clear_min1],...
                        [direct_SW_day_clear_min1],[diffus_SW_day_clear_min1],...
                        [reflec_SW_day_clear_min1],[emited_LW_day_clear_min1],...
                        [incide_LW_day_clear_min1],[zenith_day_clear_min1]);
         
        Data = outerjoin(Vector3,Vector4,'Type','left');
        [~,idx] = unique(Data(:,1));
        Data = Data(idx,:);

        [year_day_clear_min1,month_day_clear_min1,day_day_clear_min1,...
         hour_day_clear_min1,min_day_clear_min1,seg_day_clear_min1] = datevec(total_time1);
         global_SW_day_clear_min1  = Data.global_SW_day_clear_min1;
         direct_SW_day_clear_min1  = Data.direct_SW_day_clear_min1;
         diffus_SW_day_clear_min1  = Data.diffus_SW_day_clear_min1;
         reflec_SW_day_clear_min1  = Data.reflec_SW_day_clear_min1;
         emited_LW_day_clear_min1  = Data.emited_LW_day_clear_min1;
         incide_LW_day_clear_min1  = Data.incide_LW_day_clear_min1;
         zenith_day_clear_min1     = Data.zenith_day_clear_min1;
         
    end
     global_SW_day_clear_min1(global_SW_day_clear_min1<0)  = 0;
     direct_SW_day_clear_min1(direct_SW_day_clear_min1<0)  = 0;
     diffus_SW_day_clear_min1(diffus_SW_day_clear_min1<0)  = 0;
     reflec_SW_day_clear_min1(reflec_SW_day_clear_min1<0)  = 0;
     emited_LW_day_clear_min1(emited_LW_day_clear_min1<0)  = 0;
     incide_LW_day_clear_min1(incide_LW_day_clear_min1<0)  = 0;
     
     year_day_clear_min  = [year_day_clear_min;year_day_clear_min1];
     month_day_clear_min = [month_day_clear_min;month_day_clear_min1];
     day_day_clear_min   = [day_day_clear_min;day_day_clear_min1];
     hour_day_clear_min  = [hour_day_clear_min;hour_day_clear_min1];
     min_day_clear_min   = [min_day_clear_min;min_day_clear_min1];
     seg_day_clear_min   = [seg_day_clear_min;seg_day_clear_min1];
     global_SW_day_clear_min  = [global_SW_day_clear_min;global_SW_day_clear_min1];
     direct_SW_day_clear_min  = [direct_SW_day_clear_min;direct_SW_day_clear_min1];
     diffus_SW_day_clear_min  = [diffus_SW_day_clear_min;diffus_SW_day_clear_min1];
     reflec_SW_day_clear_min  = [reflec_SW_day_clear_min;reflec_SW_day_clear_min1];
     emited_LW_day_clear_min  = [emited_LW_day_clear_min;emited_LW_day_clear_min1];
     incide_LW_day_clear_min  = [incide_LW_day_clear_min;incide_LW_day_clear_min1];
     zenith_day_clear_min     = [zenith_day_clear_min;zenith_day_clear_min1];   
     
     
     end
     
        end
    
  end
 end
end


%% save data days clear sky

data_clear_select_min = [year_day_clear_min,month_day_clear_min,...
                         day_day_clear_min,hour_day_clear_min,...
                         min_day_clear_min,seg_day_clear_min,...
                         global_SW_day_clear_min,direct_SW_day_clear_min,...
                         diffus_SW_day_clear_min,reflec_SW_day_clear_min,...
                         emited_LW_day_clear_min,incide_LW_day_clear_min,...
                         zenith_day_clear_min];

dir_out  = 'output/';
filename = 'input_data_claer_sky_sbdart.dat';

str_total = [dir_out,filename];

dlmwrite(str_total,data_clear_select_min,'delimiter',' ','precision','%.3f');


