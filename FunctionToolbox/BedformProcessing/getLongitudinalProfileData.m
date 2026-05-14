function lines = getLongitudinalProfileData(lines)
% GETLONGITUDINALPROFILEDATA adds S and Z values for each line
%   GETLONGITUDINALPROFILEDATA takes in a structure of lines and computes
%   the distance along and line giving a vector S and inverts the depth
%   values for Z into psuedo elevation.
%
%   LINES = GETLONGTUDINALPROFILEDATA(LINES) takes in the proprietary
%   structure LINES and adds curvilinear values for S and Z to be used to
%   calculate profile parameters using peak and trough detection. Returns
%   the structure LINES with the added data.
%
%   Other Functions Referenced:
%       hypot(...), cumsum(...)
%
%
%   -- Matthew Free 10/2025 --

    % loop through all lines
    for i = 1:length(lines)
        % get a single line
        line = lines(i);

        % pull out the desired
        E = line.E; % easting in meters
        N = line.N; % northing in meters
        Z = line.Z; % depth in meters
                        
                    
        lengths = hypot(diff(E - min(E)), diff(N - min(N)));
        
    % Get distance along the curve (m)
        lines(i).s = [0; cumsum(lengths)];

    % Create psuedo elevation/convert to meters (m)
        lines(i).z = -Z;
    end
end