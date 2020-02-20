function [log_bissexto,nd_feb,days_year] = bissexto_03(year_i)

clear global;   

  if ( ( (mod(year_i,4)==0) && (mod(year_i,100)>0) ) || (mod(year_i,400)==0) )
	 log_bissexto = true(1); 
     nd_feb    = 29; 
     days_year = 366;     
  else
     log_bissexto = false(1); 
     nd_feb = 28; 
     days_year = 365;      
  end
  
 return
end
