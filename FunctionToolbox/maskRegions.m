function D = maskRegions(D, regions)
% MASKREGIONS masks away data given regions of intersection (ROI)
%   MASKREGIONS takes in the data structure D and masks away any data that
%   fall inside the given regions variable.
%
%   D = MASKREGIONS(D,REGIONS) masks data inside of D that fall in any of
%   the roi REGIONS. REGIONS is either a single or cell array of polygons.
%
%   Other Functions Referenced:
%       vertcat(...), false(...), numel(...), polyshape(...),
%       isinterior(...), isfield(...)
%
%
%   -- Matthew Free 05/2026 --
    
% Build combined peak coordinates
    E = vertcat(D.ProfileEastingPeak{:});
    N = vertcat(D.ProfileNorthingPeak{:});

% Initialize mask
    mask = false(size(E));

% Combine masks from all regions
    for i = 1:numel(regions)
        pos = regions{i}.Position;
        regionPoly = polyshape(pos(:,1), pos(:,2));

        mask = mask | isinterior(regionPoly, E, N);
    end

    indexStart = 1;

% Track profiles to delete
    removeProfiles = false(numel(D.ProfileL),1);

    for j = 1:numel(D.ProfileL)

        n = numel(D.ProfileL{j});

        if n == 0
            removeProfiles(j) = true;
            continue
        end

        indexEnd = indexStart + n - 1;

        submask = mask(indexStart:indexEnd);
        submask = submask(:);

    % Remove masked dunes
        D.ProfileL{j}(submask) = [];
        D.ProfileH{j}(submask) = [];
        D.Profileh{j}(submask) = [];

        D.ProfileEastingPeak{j}(submask) = [];
        D.ProfileNorthingPeak{j}(submask) = [];

    % Troughs are N+1
        D.ProfileEastingTrough{j}([false; submask]) = [];
        D.ProfileNorthingTrough{j}([false; submask]) = [];

        if ~isempty(D.ProfileRiverMile{j}) && numel(D.ProfileRiverMile{j}) == numel(submask)
            D.ProfileRiverMile{j}(submask) = [];
        end
        
        if ~isempty(D.ProfileRiverKm{j}) && numel(D.ProfileRiverKm{j}) == numel(submask)
            D.ProfileRiverKm{j}(submask) = [];
        end

        D.ProfileDuneInfo.PeakIndices{j}(submask) = [];
        D.ProfileDuneInfo.TroughIndices{j}(submask) = [];

    % Check if profile is now empty
        if isempty(D.ProfileL{j})

            removeProfiles(j) = true;

        % Ensure trough arrays are empty too
            D.ProfileEastingTrough{j} = [];
            D.ProfileNorthingTrough{j} = [];
        end

        indexStart = indexEnd + 1;
    end

% Remove fully empty profiles from all profile fields
    fields = {
        'ProfileL'
        'ProfileH'
        'Profileh'
        'ProfileEastingPeak'
        'ProfileNorthingPeak'
        'ProfileEastingTrough'
        'ProfileNorthingTrough'
        'ProfileRiverMile'
        'ProfileRiverKm'
    };

    for k = 1:numel(fields)
        field = fields{k};

        if isfield(D, field)
            D.(field)(removeProfiles) = [];
        end
    end

% Remove Profile and DuneInfo fields
    D.ProfileInfo.OffsetFromSailingLine(removeProfiles) = [];
    D.ProfileInfo.OriginalLineIndex(removeProfiles) = [];
    D.ProfileDuneInfo.S(removeProfiles) = [];
    D.ProfileDuneInfo.Z(removeProfiles) = [];
    D.ProfileDuneInfo.PeakIndices(removeProfiles) = [];
    D.ProfileDuneInfo.TroughIndices(removeProfiles) = [];
    D.Parameters.Prominence(removeProfiles) = [];

% Rebuild combined arrays
    D.L = vertcat(D.ProfileL{:});
    D.H = vertcat(D.ProfileH{:});
    D.h = vertcat(D.Profileh{:});
end