function APM = magPhase2RealImag(APM)
% MAG PHASE 2 REAL IMAG - APM real and imaginary from mag and phase
%
% APM = magPhase2RealImag(APM)
% APM must contain the fields 'A13M','A23M','A13P','A23P',
% where phases are in degrees.
%
% See also realImag2MagPhase.m

% Copyright (C) 2010 Brian M. Emery
% verified method with mag_phase_calc_experiments.m

field_check(APM,{'A13M','A23M','A13P','A23P'})

% COMPUTE REAL AND IMAGINARY COMPONENTS
% r cos(p) + r i sin(p)
% real = r cos(p)
% imag = r sin(p)
APM.A13R = APM.A13M .* cosd(APM.A13P);
APM.A13I = APM.A13M .* sind(APM.A13P);

APM.A23R = APM.A23M .* cosd(APM.A23P);
APM.A23I = APM.A23M .* sind(APM.A23P);

end