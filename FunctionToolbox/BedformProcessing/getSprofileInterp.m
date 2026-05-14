function [sout,zout,eout,nout,dout] = getSprofileInterp(sin,zin,ein,nin,din)
% GETSPROFILEINTERP interpolates data
%   GETSPROFILEINTERP takes in the vector s and finds the optimal
%   difference to interpolate to a set frequency. Interpolates other data
%   to match.
%
%   [SOUT,ZOUT,EOUT,NOUT,DOUT] = GETSPROFILEINTERP(SIN,ZIN,EIN,NIN,DIN)
%   takes in each of the data vectors and interpolates to a common sample
%   spacing
%
%   Other Functions Referenced:
%       diff(...), abs(...), min(...), diffnorm(...), mean(...), max(...),
%       interp1(...)
%
%
%   -- Matthew Free 10/2025 --

% difference between adjacent s readings
    diffs = diff(sin);
% get minimum difference
    dsmin = abs(min(diffs));
% normalize all with min difference
    diffnorm = diffs./dsmin;
% disregard higher ones assuming they are multiples and nothing more than 10% deviates in real ds
    diffnorm_filt = diffnorm(diffnorm < 1.10);
    ds = mean(diffnorm_filt);
% Interpolate all data
    sout = min(sin):ds:max(sin);
    zout = interp1(sin,zin,sout);
    eout = interp1(sin,ein,sout);
    nout = interp1(sin,nin,sout);
    dout = interp1(sin,din,sout);
% Set to all column vectors
    sout = sout(:);
    zout = zout(:);
    eout = eout(:);
    nout = nout(:);
    dout = dout(:);
end