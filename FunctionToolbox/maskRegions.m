function D = maskRegions(D,regions)
    for i = 1:numel(regions)
        region = regions{i};
        pos = region.Position;
        region = polyshape(pos(:,1), pos(:,2));
        
        E = vertcat(D.ProfileEastingPeak{:});
        N = vertcat(D.ProfileNorthingPeak{:});

        mask = isinterior(region,E,N);

        D.L(mask) = [];
        D.H(mask) = [];
        D.h(mask) = [];
        
        indexStart = 1;

        for j = 1:numel(D.ProfileL)
            n = numel(D.ProfileL{j});
            indexEnd = indexStart + n - 1;
        
            if indexEnd > numel(mask)
                indexEnd = numel(mask);
            end
        
            submask = mask(indexStart:indexEnd);
            submask = submask(:);
            
            D.ProfileL{j}(submask) = [];
            D.ProfileH{j}(submask) = [];
            D.Profileh{j}(submask) = [];
            D.ProfileEastingPeak{j}(submask) = [];
            D.ProfileNorthingPeak{j}(submask) = [];
            D.ProfileEastingTrough{j}([false; submask]) = [];
            D.ProfileNorthingTrough{j}([false; submask]) = [];
            if ~isnan(D.ProfileRiverMile{j}(1))
                D.ProfileRiverMile{j}(submask) = [];
                D.ProfileRiverKm{j}(submask) = [];
            end
            D.ProfileDuneInfo.PeakIndices{j}(submask) = [];
            D.ProfileDuneInfo.TroughIndices{j}(submask) = [];
        
            indexStart = indexEnd + 1;
        
            if indexStart > numel(mask)
                break
            end
        end
    end
end