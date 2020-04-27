# Introduction
clearskyalgorithm is an algorithm to select clear sky conditions from uv irradiance surface at 340 nm measured intervals of 1 minute.

## Wavelet transform method

The wavelet method is based on the decomposition of UV radiation measured at 340 nm with 1 minute interval.
The algorithm detects the spectral signatures of the clouds and the magnitude of the noise in the daily 
UV irradiance, similar approach to 2017. The decision whether or not we have a clear day is taken from 
the analysis of the decomposition by analyzing some criteria. Firstly, a Gaussian adjustment curve is 
generated from the UV irradiance data for each measurement day. As a condition for a day to be selected 
as a clear-sky condition, it is required that the determination coefficient be greater than or equal to 0.982, 
the Root Mean Square Error (RMSE) less than 0.04 W m<sup>-2</sup> and the length measurement day be greater to 600. 
Once this condition is satisfied, the wavelet method is applied.

## Normalized method


### Contact
Jose Flores, jflores@igp.gob.pe
Christian Torres, christian1994@furg.br <br>
