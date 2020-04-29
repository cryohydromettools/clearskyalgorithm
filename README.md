# Introduction

Clearskytool is a tool in Matlab to select clear sky conditions from UV irradiance surface at 340 nm 
measured intervals of one minute. We describe two methods to identify clear sky days.

***1***. **Wavelet transform method**

The algorithm detects the spectral signatures of the clouds and the magnitude of the noise in the daily. Wavelet 
method is based on the decomposition of the UV irradiance measured at 340 nm with 1 minute interval. 
This method is based a similar approach to Djafer et al. (2017). The decision if we have or not a clear day 
is taken from the decomposition analysis considering some criterios. Firstly, a Gaussian adjustment curve 
is generated from the UV irradiance data for each measurement day. In our case, e.g., as a condition for a 
day to be selected as a clear sky condition, it is required that the determination coefficient (rsquare_in) be 
greater than or equal to 0.982, the Root Mean Square Error (rmse_in) less than 0.025 W m<sup>-2</sup> and 
the measurements per day (len_in) greater than 600 minute measurements per day. Once these conditions are 
satisfied, the wavelet transform method is applied to identify measurements influenced by clouds.

***2***. **Normalized method**

Normalized method is based on the calculation of normalized UV irradiance measured at 340 nm with one minute 
interval, using the power law equation of the cosine of the solar zenith angle (SZA). This method was used to 
identify clear sky Global irradiance by Long and Ackerman (2000) and UV irradiance by Suárez Salas et al. (2017).
The power law equation depending a and b regression coefficients. The a coefficient determine maximum (sup_lim) 
and minimum (inf_lim01, inf_lim02) threshold for our data set. The automation process to detect the a and b (bcoef)
coefficients, which are representative of the entire irradiance dataset, lies in iteration. For first iteration, 
it can be proposed initial coefficients take from the scientific literature or found clear sky day using wavelet 
transform method. In our case, e.g., for first iteration, these initial coefficients were obtained from the 
scientific literature (e.g., Suárez Salas et al., 2017), bcoef equal to 1.30, sup_lim equal to 0.82 
W m<sup>-2</sup>, inf_lim01 equal to 0.62 W m<sup>-2</sup> and inf_lim02 to 0.58 W m<sup>-2</sup>. After the 
first iteration, the algorithm uses the results from fitting the previosly detected clear sky measurements, 
and succeeding iterations refine the process to the actual characteristics of the themselves.
The final values for the coefficients are obtained after the automation process.    

Both methods identify clear sky days from UV irradiance measured at 340 nm with one minute interval. In addition, 
normalized method can identify short periods by day and its process for find the a and b coefficients is 
automatic. In contrast, wavelet method only identifies completely clear days and the process for find 
rsquare_in and rmse_in coefficients is manual.

### Contact

Christian Torres, christian1994@furg.br <br>
Jose Flores, jflores@igp.gob.pe

# Scripts

**wavelet_transform_method** - The function reads the time and date of sampling (MATLAB time [days since year 0]), 
rainfall intensity (mm / h), reflectivity (dBZ), synoptic codes SYNOP 4680 and 4677 
(see PARSIVEL2 manual), drop concentration (log [1 / m mm]),and raw data of sizes versus velocity (1).

**normalized_method** - The following function is useful for combining the information of several files into a single structure.
The function uses input an array of data structures and assembles it into one.

**plot_clear_sky_days** - The following script is for cutting structures that have more 
data than desired. The function uses input a data structure and the start and end times 
that interest and throws a new structure with the indicated period.

## Structure

**wavelet_transform_method**

```Matlab

    dir work section
	
	dir_out            = dir output
	dir_graph          = dir graphics 
	dir_in             = dir input
	filename_in        = file name data set
	filename_out       = file output name wavelet transform method 
	filename_out_thres = file output name threshold normalized method
    
    input years and location section
	
	years_total = years work e.g. [2018,2019,2020]
	lon_s       = logitude   e.g. [-75.30]
	lat_s       = latiude    e.g. [-12.04]
	elv_s       = elevation  e.g. [3314.0]
	zone_s      = zone UTC   e.g. [-5]

    conditions select day  section    

	rsquare_in = determination coefficient e.g. [0.982]
	rmse_in    = Root Mean Square Error    e.g. [0.025]
	len_in     = the measurements per day  e.g. [600]

	
```

**normalized_method**

```Matlab

    dir work section
	
	dir_out            = dir output
	dir_graph          = dir graphics 
	dir_in             = dir input
	filename_in        = file name data set
	filename_out       = file output name normalized method 
    
    input years and location section
	
	years_total = years work e.g. [2018,2019,2020]
	lon_s       = logitude   e.g. [-75.30]
	lat_s       = latiude    e.g. [-12.04]
	elv_s       = elevation  e.g. [3314.0]
	zone_s      = zone UTC   e.g. [-5]

    conditions select short period  section    

	bcoef       = b coefficient initial     e.g. [1.30]
	sup_lim     = threshold max             e.g. [0.82]
	inf_lim01   = threshold min < 78.5° SZA e.g. [0.62] 
	inf_lim02   = threshold min > 78.5° SZA e.g. [0.58]

	
```

## Examples


** head data file guv_data_all_f.txt** 
|C|Variable name|Short Name|Unit|
|---|---|---|---|
|C1| Year | year |  |
|C2| Month | month |  |
|C3| Day | day |  |
|C4| Hour | hour |  |
|C5| Minute | min |  |
|C6| Second| sec | |
|C7| Irradiance at 305 | irra_305 | W m<sup>-2</sup> nm<sup>-1</sup> |
|C8| Irradiance at 320 | irra_320 | W m<sup>-2</sup> nm<sup>-1</sup> |
|C9| Irradiance at 340 | irra_340 | W m<sup>-2</sup> nm<sup>-1</sup> |
|C10| Irradiance at 380 | irra_380 | W m<sup>-2</sup> nm<sup>-1</sup> |
|C11| Erythemal dose maximum | dose_max |  |
|C12| Erythemal dose mean | dose_mean |  |
|C13| Erythemal dose minimum | dose_min |  |

# References

Djafer, D., Irbah, A., and Zaiani, M. (2017). Identification of clear days from solar irradiance observations using 
a new method based on the wavelet transform. Renewable Energy, 101, 347-355. https://doi.org/10.1016/J.RENENE.2016.08.038

Long, C. N., and Ackerman, T. P. (2000). Identification of clear skies from broadband pyranometer measurements and 
calculation of downwelling shortwave cloud effects. Journal of Geophysical Research: Atmospheres, 105(D12), 
15609-15626. https://doi.org/10.1029/2000JD900077

Suárez Salas, L. F., Flores Rojas, J. L., Pereira Filho, A. J., and Karam, H. A. (2017). Ultraviolet solar radiation 
in the tropical central Andes (12.0°S). Photochemical & Photobiological Sciences, 16(6), 954-971. 
https://doi.org/10.1039/C6PP00161K

