function props = maskData(props, mask)
% MASKDATA removes data within a specified range.
%   MASKDATA uses a mask from the interpolated longitudinal vector and
%   removes and data points that lie within any part of the logical mask 
%   that is true
%
%   PROPS = MASKDATA(PROPS, MASK) removes all data from the data structure
%   PROPS and returns that data structure PROPS. PROPS structure is the 
%   output of the duneLengthHeight function.
%
%   Other Functions Referenced:
%       length(...), false(...), any(...), isnan(...)
%
%
% -- Matthew Free 04/2026 --

%% Remove Dune Characteristics
    numDunes = length(props.troughIndices) - 1;

    badDuneMask = false(numDunes, 1);
    
    for i = 1:numDunes
        iStart = props.troughIndices(i);
        iEnd = props.troughIndices(i + 1);
    
        if any(mask(iStart:iEnd))
            badDuneMask(i) = true;
        end
    end

    % Remove Dunes for Each Field in Props
    fields = ["inclinedLength", "verticalHeight", "slope", "inclinedAngle", ...
              "lengthStoss", "lengthLee", "heightStoss", "heightLee", ...
              "totalLength", "avgHeight"];

    valid = ~badDuneMask;

    for f = fields
        props.(f) = props.(f)(valid);
    end

%% Edit Trough and Peak Indices
    if ~isempty(props.troughIndices)

        % remove bad peaks
        props.peakIndices = props.peakIndices(valid);

        % remove corresponding right-side trough (i+1)
        keepTrough = [true; valid];

        props.troughIndices = props.troughIndices(keepTrough);

        % NaN out masked values for S and Z
        props.smoothS(mask) = NaN;
        props.smoothZ(mask) = NaN;
    end
end