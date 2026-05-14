function bedform = duneHeightLength(X, Y, prominence, mask)
% DUNEHEIGHTLENGTH Gets bedform characteristics from x and y vectors
%   DUNEHEIGHTLENGTH allows for quick and easy analysis of river dune
%   characteristics, such as length, height, peak and trough locations, and
%   stoss and lee.
%
%   BEDFORM = DUNEHEIGHTLENGTH(X,Y) takes vectors X and Y as arguments and
%   computes the bedform characteristics returning the BEDFORM structure. A
%   default PROMINENCE value of 1 is used.
%
%   BEDFORM = DUNEHEIGHTLENGTH(X,Y,PROMINENCE) takes vectors X and Y as
%   arguments as well as a specified PROMINENCE value. A higher PROMINENCE
%   value filters out smaller BEDFORM characteristics.
%
%   BEDFORM is a struct containing the following fields:
%       PEAKINDICES: the indices on X and Y where peaks occur
%       TROUGHINDICES: the indices on X and Y where troughs occur
%       INCLINEDLENGTH: the straightline distance between troughs
%       VERTICALHEIGHT: the vertical distance between peaks and inclinedlength
%       SLOPE: the slope of the inclined lengths
%       INCLINEDANGLE: the angle of the slope/ angle between troughs
%       LENGTHSTOSS: the stoss length between peak and trough
%       HIGHTSTOSS: the stoss height between peak and trough
%       LENGTHLEE: the lee length between peak and trough
%       HEIGHTLEE: the lee height between peak and trough
%       TOTALLENGTH: the horizontal distance between troughs
%       AVGHEIGHT: the average between stoss and lee heights
%   
%   Other Functions Referenced:
%       findpeaks(...), pythagoreanTheorem(...), pointSlopeHeight(...),
%       duneStossAndLee(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        X double
        Y double
        prominence (1, 1) double = 1;
        mask = zeros(length(X));
    end

%% Get Peaks and Troughs
    % Peaks
        [~, peakIdx] = findpeaks(Y, "MinPeakProminence", prominence);
        
    % Troughs
        [~, troughIdx] = findpeaks(-Y, "MinPeakProminence", prominence);
        
        allIdx = sort([troughIdx'; peakIdx']);
        isPeak = ismember(allIdx, peakIdx);

    % Ensure start is trough
        while ~isempty(isPeak) && isPeak(1)
            allIdx(1) = [];
            isPeak(1) = [];
        end

    % Ensure alternation
        bad = [false; diff(isPeak) == 0];
        allIdx(bad) = [];
        isPeak(bad) = [];

    % Ensure end is trough
        while ~isempty(isPeak) && isPeak(end)
            allIdx(end) = [];
            isPeak(end) = [];
        end
        
    % Get peaks and troughs
        bedform.troughIndices = allIdx(~isPeak);
        bedform.peakIndices   = allIdx(isPeak);
        
        troughs = Y(bedform.troughIndices);
        peaks = Y(bedform.peakIndices);

%% Calculate Dune Heights and Lengths
    % Inclined Length
        bedform.inclinedLength = pythagoreanTheorem(X(bedform.troughIndices), troughs);
    
    % Vertical Height and Slope
        [bedform.verticalHeight, bedform.slope] = pointSlopeHeight(X(bedform.troughIndices), troughs, X(bedform.peakIndices), peaks);
    
    % Angle of Incline
        bedform.inclinedAngle = atan(bedform.slope).*(180/pi);
    
    % Length Stoss/Lee and Height Stoss/Lee
        [bedform.lengthStoss, bedform.lengthLee, bedform.heightStoss, bedform.heightLee] = duneStossAndLee(X(bedform.troughIndices), troughs, X(bedform.peakIndices), peaks);
    
    % Total Length
        bedform.totalLength = bedform.lengthLee + bedform.lengthStoss;
    
    % Average Height
        bedform.avgHeight = (bedform.heightLee + bedform.heightStoss)/2;

    % Input Data
        bedform.smoothS = X;
        bedform.smoothZ = Y;

    % Mask data
        bedform = maskData(bedform, mask);
end

