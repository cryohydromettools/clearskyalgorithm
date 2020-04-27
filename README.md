# Introduction
clearskyalgorithm is an algorithm to select clear sky conditions from uv irradiance surface at 340 nm measured intervals of 1 minute.

### Wavelet transform method

Wavelet method is based on the decomposition of UV radiation measured at 340 nm with 1 minute interval.
The algorithm detects the spectral signatures of the clouds and the magnitude of the noise in the daily 
UV irradiance, similar approach to Djafer et al. (2017). The decision whether or not we have a clear day is taken from 
the analysis of the decomposition by analyzing some criteria. Firstly, a Gaussian adjustment curve is 
generated from the UV irradiance data for each measurement day. As a condition for a day to be selected 
as a clear-sky condition, it is required that the determination coefficient be greater than or equal to 0.982, 
the Root Mean Square Error (RMSE) less than 0.04 W m<sup>-2</sup> and the length measurement day be greater to 600. 
Once this condition is satisfied, the wavelet method is applied.

### Normalized method


## Contact

Christian Torres, christian1994@furg.br <br>
Jose Flores, jflores@igp.gob.pe

# References

Djafer, D., Irbah, A., and Zaiani, M. (2017). Identification of clear days from solar irradiance observations using 
a new method based on the wavelet transform. Renewable Energy, 101, 347-355. https://doi.org/10.1016/J.RENENE.2016.08.038

Long, C. N., y Ackerman, T. P. (2000). Identification of clear skies from broadband pyranometer measurements and 
calculation of downwelling shortwave cloud effects. Journal of Geophysical Research: Atmospheres, 105(D12), 
15609-15626. https://doi.org/10.1029/2000JD900077

Suárez Salas, L. F., Flores Rojas, J. L., Pereira Filho, A. J., y Karam, H. A. (2017). Ultraviolet solar radiation 
in the tropical central Andes (12.0°S). Photochemical & Photobiological Sciences, 16(6), 954-971. 
https://doi.org/10.1039/C6PP00161K

