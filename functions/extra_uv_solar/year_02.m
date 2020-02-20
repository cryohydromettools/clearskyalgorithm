function [year_r,month_r,day_r,hour_r,min_r,...
          log_bissexto,n_day_r,n_days_year,...
          year_rad] = year_02(year_i,month_i,day_i,hour_i,min_i,seg_r)
     
 clear global;     
 nd = [31,28,31,30,31,30,31,31,30,31,30,31]; % sum = 365 days
            
 % Function to evaluate if the year is bissexto 
 [log_bissexto,nd(2),n_days_year] = bissexto_03(year_i);

  sum_0d=0.0;

    if(month_i >= 2)  
      for i = 1:month_i-1
		sum_0d = sum_0d + double(nd(i)); 
      end
    end 

	 min_r = double(min_i) + seg_r/60.0;

	 hour_r = double(hour_i) + min_r/60.0;

	 day_r = double(day_i-1) + (hour_r/24.0);

	 n_day_r = sum_0d + day_r;

	 month_r  = double(month_i-1) + day_r / double(nd(month_i));

     year_r  = double(year_i)+( n_day_r / n_days_year );

     year_rad = (n_day_r /n_days_year)*2.*pi;  
     
 return
      
      
      