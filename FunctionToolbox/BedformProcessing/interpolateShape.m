function lines = interpolateShape(x,y,z,lines)
% INTERPOLATESHAPE interpolates data along set lines
%   INTERPOLATESHAPE takes in raw 3D data and interpolates along a set path
%   to create 3D curves in space. These are used as the BEPs analyzed
%   through peak trough detection
%
%   LINES = INTERPOLATESHAPE(X,Y,Z,LINES) takes in raw data X, Y, and Z as
%   well as the proprietary data structure LINES. The vertical data Z is then
%   added to each line within the LINES structure.
%
%   Other Functions Referenced:
%       scatteredInterpolant(...), KDTreeSearcher(...), rng(...),
%       randperm(...), knnsearch(...), mean(...), numel(...), isnan(...)
%
%
%   -- Matthew Free 01/2026 --

%% Arguments
    arguments
        x 
        y 
        z 
        lines 
    end

%% Create Scattered Interpolant Object
    % Create Scattered interpolant and KDTree
        F = scatteredInterpolant(x(:), y(:), z(:), 'linear', 'none');
        KDTree = KDTreeSearcher([x(:), y(:)]);

    % Compute the Nearest Neighbor Distance
        rng(1) % set rng for consistency
        samplePoints = randperm(numel(x), round(0.05*numel(x)));
        [~, nearestNeighbor] = knnsearch([x(:), y(:)], [x(samplePoints), y(samplePoints)], "K", 2);
        maxDistance = mean(nearestNeighbor(:,2));

%% Interpolate Along Each Line
    for i = 1:numel(lines)
    % Calculate each BEP
        E = lines(i).E;
        N = lines(i).N;
        Z = F(E, N);

    % Remove invalid interpolated values
        [~, distances] = knnsearch(KDTree, [E', N']);
        Z(distances > maxDistance) = NaN;
        valid = ~isnan(Z);
        lines(i).E = E(valid)';
        lines(i).N = N(valid)';
        lines(i).Z = Z(valid)';
    end
end