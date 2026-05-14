function zrec = getWtHPF(z,ds,Lthresh)
% GETWTHPF performs a high pass filter
%   GETWTHPF takes in z data and filters out frequencies below a threshold
%   using the wavelet transform
%
%   ZREC = GETWTHPF(Z,DS,LTHRESH) takes the raw data Z and the samples
%   spacing DS and removes frequencies below LTHRESH
%
%   Other Functions Referenced:
%       cwt(...), icwt(...), max(...), min(...)
%
%
%   -- Matthew Free 09/2025 --

% Remove frequencies outside of the threshold
    [wt,f] = cwt(z,1/ds);
    zrec = icwt(wt, 'Morse', f, [max((1/Lthresh),min(f)), max(f)]);
end

