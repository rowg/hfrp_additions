% HFRP Additions  
% Version 1.0   
%  
% Brian Emery 22 May 2011  
% emery@msi.ucsb.edu  
%   
% CONTENTS.M - Descriptions of my HFRProgs Additions  
%  
% FILE READ, WRITE, INITIALIZING  
%   ctfReader.m       - Read Codar Table Format files    
%   ctfWriter.m       - Write Codar Table Format files  
%   read_cs.m         - Read one or all ranges in a Cross Spectra File  
%   loadRDLFile.m     - modified HFRP tool, adds ancillary data to OtherMatrixVariables   
%
% SPECIFIC TO RADIAL DATA STRUCTURES  
%   temporalConcatRadials_exact.m  - like the HFRP tool, but uses exact locations  
%   radial_display.m               - make colored radial sector plots like Codar's Radial Display  
%   smooth_in_bearing.m            - apply smoothing to radials in bearing  
%   radial_comparison.m            - baseline comparisons of radials from 2 sites  
%  
% OTHER USEFUL TOOLS  
%   cosFileNameParts.m    - Parse file name into site, date, file type, etc  
%   cos_totals_to_hfrp.m  - Convert Codar total format into HFRP TUV struct  
%   interp_to_codar.m     - Get hf derived velocity given position and time arrays  
%   lonlat2km_new.m       - Km East and North relative to origin using Vincenty's  
%   km2lonlat_new.m       - Convert Km to lon lat from origin using Vincenty's  
%  
% NOTES  
% The /private subfolder contains any mfiles that are used by the above,  
% and may contain redundant copies from other toolboxes.  
%  
% Any and all feedback welcome!  




