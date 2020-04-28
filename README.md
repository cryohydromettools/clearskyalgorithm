# Introduction

Matlab toolbox to select clear sky conditions from uv irradiance surface at 340 nm measured intervals of 1 minute.
We describe two methods to identify clear sky days.

***1***. **Wavelet transform method**

Wavelet method is based on the decomposition of UV irradiance measured at 340 nm with 1 minute interval.
The algorithm detects the spectral signatures of the clouds and the magnitude of the noise in the daily 
UV irradiance, similar approach to Djafer et al. (2017). The decision whether or not we have a clear day is taken from 
the analysis of the decomposition by analyzing some criteria. Firstly, a Gaussian adjustment curve is 
generated from the UV irradiance data for each measurement day. As a condition for a day to be selected 
as a clear-sky condition, it is required that the determination coefficient be greater than or equal to 0.982, 
the Root Mean Square Error (RMSE) less than 0.04 W m<sup>-2</sup> and the length measurement day be greater to 600. 
Once this condition is satisfied, the wavelet method is applied.

***2***. **Normalized method**

Normalized method is based on the calculation of normalized UV irradiance measured at 340 nm with 1 minute interval, 
as power law function of the cosine of the solar senith angle (SZA). This method was used to identify celar sky 
Global irradiance by Long and Ackerman (2000) and UV irradiance by Suárez Salas et al. (2017).  

## Contact

Christian Torres, christian1994@furg.br <br>
Jose Flores, jflores@igp.gob.pe

## Scripts

**wavelet_clear_sky_days** - The function reads the time and date of sampling (MATLAB time [days since year 0]), 
rainfall intensity (mm / h), reflectivity (dBZ), synoptic codes SYNOP 4680 and 4677 
(see PARSIVEL2 manual), drop concentration (log [1 / m mm]),and raw data of sizes versus velocity (1).

**select_clear_sky_min_total** - The following function is useful for combining the information of several files into a single structure.
The function uses input an array of data structures and assembles it into one.

**clear_sky_days_plot** - The following script is for cutting structures that have more 
data than desired. The function uses input a data structure and the start and end times 
that interest and throws a new structure with the indicated period.

# References

Djafer, D., Irbah, A., and Zaiani, M. (2017). Identification of clear days from solar irradiance observations using 
a new method based on the wavelet transform. Renewable Energy, 101, 347-355. https://doi.org/10.1016/J.RENENE.2016.08.038

Long, C. N., and Ackerman, T. P. (2000). Identification of clear skies from broadband pyranometer measurements and 
calculation of downwelling shortwave cloud effects. Journal of Geophysical Research: Atmospheres, 105(D12), 
15609-15626. https://doi.org/10.1029/2000JD900077

Suárez Salas, L. F., Flores Rojas, J. L., Pereira Filho, A. J., and Karam, H. A. (2017). Ultraviolet solar radiation 
in the tropical central Andes (12.0°S). Photochemical & Photobiological Sciences, 16(6), 954-971. 
https://doi.org/10.1039/C6PP00161K

