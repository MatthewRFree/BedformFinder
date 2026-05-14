function Data = getProfileData(filename, BEPs, riverLine, thresholdHPF, primaryProminence)
% GETPROFILEDATA Gathers and computes profile information
%   GETPROFILEDATA takes a set of profiles and computes the bedform dimensions
%   using peak and trough detection.
%
%   DATA = GETPROFILEDATA(FILENAME, BEPS, RIVERLINE) takes the specified file FILENAME
%   and returns the data structure. BEPS is a proprietary structure of elevation profiles
%   and RIVERLINE is a table of the Easting, Northing, and River mile points
%   for the line used to create the BEPs. A default THRESHOLDHPF or the 
%   maximum high pass filter value of 75 is set. A default value of nan is 
%   set for the prominence PRIMARYPROMINENCE.
%   
%   DATA = GETPROFILEDATA(..., THRESHOLDHPF, PRIMARYPROMINENCE) takes a
%   maximum high pass filter value THRESHOLDHPF and a prominence value
%   PRIMARYPROMINENCE as arguments.
%
%   Other Functions Referenced:
%       exist(...), load(...), strcat(...), num2str(...), length(...),
%       getSprofileInterp(...), getWtHPF(...), isempty(...), min(...),
%       diff(...), isrow(...), mean(...), curveSmoothing(...), duneHeightLength(...)
%
%
% -- Matthew Free 05/2025 --

%% Arguments
    arguments
        filename
        BEPs
        riverLine table
        thresholdHPF double = 75;
        primaryProminence double = nan;
    end

%% Temporary Variables
     % Get Date
        pieces = filename.split("_");
        if length(pieces) > 1
            date = pieces(4);
            date = datetime(strcat(extractBetween(date,1,4), "-", extractBetween(date,5,6), "-", extractBetween(date,7,8)));
        else
            date = nan;
        end
    
    % Get River Mile
        riverMiles = extractRiverMilesFromFilename(filename);
        riverMileStart = min(riverMiles);
        riverMileEnd = max(riverMiles);
 
    % Survey Info
        Data = initializeDataStructure;
        Data.Filename = filename;
        Data.Date = date;
        Data.RiverKmStart = unitConversion(riverMileStart,"mi","km");
        Data.RiverKmEnd = unitConversion(riverMileEnd,"mi","km");
        Data.RiverMileStart = riverMileStart;
        Data.RiverMileEnd = riverMileEnd;
        Data.Parameters.HighPassFilterThreshold = thresholdHPF;

%% Get Data
    for i = 1:length(BEPs)
        
        if (length(BEPs(i).s) > 50)
        % Interpolate and use High Pass Filter
            [sInterp, zInterp, Easting_values, Northing_values, Depth_values] = getSprofileInterp(BEPs(i).s, BEPs(i).z, BEPs(i).E, BEPs(i).N, BEPs(i).Z);
            
            mask = createMask(BEPs(i).s, sInterp);

            if (~isempty(sInterp))
                zInterp = getWtHPF(zInterp, min(diff(sInterp)), thresholdHPF);

            % Calculate a Prominence
                if isnan(primaryProminence)
                   prominence = calculateProminence(sInterp, zInterp);
                else
                    prominence = primaryProminence;
                end

            % Convert from meters to feet and miles
                sInterp = unitConversion(sInterp,"m","mi");
                zInterp = unitConversion(zInterp,"m","US survey ft");

            % Lightly smooth data
                [smoothS, smoothZ] = curveSmoothing(sInterp, zInterp, 1, 2);

            % Find the Bedform scales
                propsPrim = duneHeightLength(smoothS, smoothZ, prominence, mask);
            
            % Only keep peaks that lie between the first and last trough
                if ~isempty(propsPrim.troughIndices)
                    validPeakMask = propsPrim.peakIndices > propsPrim.troughIndices(1) &... 
                    propsPrim.peakIndices < propsPrim.troughIndices(end);
                else
                    continue
                end
                validPeaks = propsPrim.peakIndices(validPeakMask);

            % Get depth values at those peak and trough locations
                duneDepths.trough = Depth_values(propsPrim.troughIndices);
                duneEastings.troughs = Easting_values(propsPrim.troughIndices);
                duneNorthings.troughs = Northing_values(propsPrim.troughIndices);

                duneDepths.peaks = Depth_values(validPeaks);
                duneEastings.peaks = Easting_values(validPeaks);
                duneNorthings.peaks = Northing_values(validPeaks);
            
            % Save Dune Heights and Lengths
                Data.L = [Data.L; propsPrim.totalLength(:)];
                Data.H = [Data.H; propsPrim.avgHeight(:)];
                Data.h = [Data.h; duneDepths.peaks(:) + propsPrim.avgHeight(:)./2];

                Data.ProfileL{end+1,1} = propsPrim.totalLength(:);
                Data.ProfileH{end+1,1} = propsPrim.avgHeight(:);
    
                Data.Profileh{end+1,1} = duneDepths.peaks(:) + propsPrim.avgHeight(:)./2;
                if width(riverLine) > 2

                    rm = getRiverMileFromCoordInterpolated(duneEastings.peaks, duneNorthings.peaks, riverLine, 0.0001);
                else
                    rm = nan;
                end
                Data.ProfileRiverMile{end+1,1} = rm;
                Data.ProfileRiverKm{end+1,1} = unitConversion(rm,"mi","km");
                Data.ProfileEastingPeak{end+1,1} = duneEastings.peaks(:);
                Data.ProfileNorthingPeak{end+1,1} = duneNorthings.peaks(:);
                Data.ProfileEastingTrough{end+1,1} = duneEastings.troughs(:);
                Data.ProfileNorthingTrough{end+1,1} = duneNorthings.troughs(:);
                Data.ProfileInfo.OffsetFromSailingLine(end+1,1) = BEPs(i).offset;
                Data.ProfileInfo.OriginalLineIndex(end+1,1) = BEPs(i).index;
                Data.ProfileDuneInfo.S{end+1,1} = propsPrim.smoothS(:);
                Data.ProfileDuneInfo.Z{end+1,1} = propsPrim.smoothZ(:);
                Data.ProfileDuneInfo.PeakIndices{end+1,1} = propsPrim.peakIndices(:);
                Data.ProfileDuneInfo.TroughIndices{end+1,1} = propsPrim.troughIndices(:);
                Data.Parameters.Prominence(end+1,1) = primaryProminence;
            end
        end
    end
    clear("getRiverMileFromCoordInterpolated")
end