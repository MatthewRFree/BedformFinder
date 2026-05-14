function lineCopies = getInterpolationLines(Easting,Northing,coord,radius,copyRight,copyLeft,fs,offset,method)
% GETINTERPOLATIONLINES creates parallel copies of a line
%   GETINTERPOLATIONLINES takes in a specified line and other parameters
%   and makes copies of that line to be used as profiles.
%
%   LINECOPIES = GETINTERPOLATIONLINES(EASTING,NORTHING,COORD,RADIUS,COPYRIGHT,COPYLEFT,...)
%   takes the Easting and Northings values for a reference line EASTING and
%   NORTHING, as well as a center coordinate COORD and a radius RADIUS. The
%   reference line is trimmed to fit within the bounding box defined by
%   COORD and RADIUS. COPYRIGHT and COPYLEFT define the number of copies to
%   make to the left and the right.
%
%   LINECOPIES(...,FS,OFFSET,METHOD) takes in the desired data frequency FS
%   and the offset distance between line copies OFFSET and the desired
%   interpolation method METHOD. Values of 1, 10, and "linear" are used by
%   default respectively.
%
%   Other Functions Referenced:
%       hypot(...), any(...), error(...), gradient(...), sign(...),
%       find(...), struct(...), interpLine2D(...)
%
%
%   -- Matthew Free 11/2025 --

%% Arguments
    arguments
        Easting
        Northing
        coord
        radius
        copyRight
        copyLeft
        fs = 1;
        offset = 10;
        method {mustBeMember(method, ['linear','pchip'])} = 'linear'
    end

%% Create line copies
    % Trim the river line
        dist = hypot(Easting - coord(1), Northing - coord(2));
        
        inside = dist <= radius;
        if ~any(inside)
            error('No points fall within %.2f units of the coordinate center.', radius);
        end
        
        E = Easting(inside);
        N = Northing(inside);

    % Compute the normals
        dE = gradient(E);
        dN = gradient(N);
        L = hypot(dE, dN);
    
        tangentE = dE ./ L;
        tangentN = dN ./ L;
    
        rightNormalE = tangentN;
        rightNormalN = -tangentE;
        leftNormalE = -tangentN;
        leftNormalN = tangentE;
    
    for k = 1:copyRight
        % Copy the points
            copyE = E + (offset * k) * rightNormalE;
            copyN = N + (offset * k) * rightNormalN;
    
        % Direction signs
            de = sign(diff(copyE));
            dn = sign(diff(copyN));
        
            dE0 = sign(diff(E));
            dN0 = sign(diff(N));
    
        % Allow small regions and accept same-direction or zero
            sameDir = (de == dE0 | de == 0 | dE0 == 0) & ...
                      (dn == dN0 | dn == 0 | dN0 == 0);
    
        % Keep first point and all consistent direction points
            filter = [true; sameDir];
    
        % Stop at first inconsistency to avoid partial loops (when overlapping)
            badIdx = find(~filter, 1);
            if ~isempty(badIdx)
                filter(badIdx:end) = false;
            end
        
        % Complete line copy points
            copyRightLines{k,1} = struct('E', copyE(filter), 'N', copyN(filter));
    end
    
    for k = 1:copyLeft
        % Copy the points
            copyE = E + (offset * k) * leftNormalE;
            copyN = N + (offset * k) * leftNormalN;
        
        % Direction signs
            de = sign(diff(copyE));
            dn = sign(diff(copyN));
        
            dE0 = sign(diff(E));
            dN0 = sign(diff(N));
        
        % Allow small regions and accept same-direction or zero
            sameDir = (de == dE0 | de == 0 | dE0 == 0) & ...
                      (dn == dN0 | dn == 0 | dN0 == 0);
        
        % Keep first point and all consistent direction points
            filter = [true; sameDir];
            badIdx = find(~filter, 1);
            if ~isempty(badIdx)
                filter(badIdx:end) = false;
            end
        
        % Complete line copy points
            copyLeftLines{k,1} = struct('E', copyE(filter), 'N', copyN(filter));
    end

%% Compile Line Copies
    % Initilize stucture
        lineCopies = struct('E', {}, 'N', {}, 'side', {}, 'index', {}, 'offset',{});
    % Fill with the original line
        lineCopies(end+1) = struct('E', E, 'N', N, 'side', 'center', 'index', 1, 'offset', 0);
    % Add right line data
        for k = 1:copyRight
            lineCopies(end+1) = struct('E', copyRightLines{k}.E, 'N', copyRightLines{k}.N, 'side', 'right', 'index', 2*k, 'offset', offset * k);
        end
    % Add left line data
        for k = 1:copyLeft
            lineCopies(end+1) = struct('E', copyLeftLines{k}.E, 'N', copyLeftLines{k}.N, 'side', 'left', 'index', 2*k+1, 'offset', -offset * k);
        end
    % Interpolate lines to desired sample spacing
        for i = 1:length(lineCopies)
            [lineCopies(i).E,lineCopies(i).N] = interpLine2D(lineCopies(i).E,lineCopies(i).N,fs,method);
        end
end

function [interpE, interpN] = interpLine2D(E,N,fs,method)
    % Get a standard sample spacing value
        numberOfPoints = round(sum(hypot(diff(E), diff(N))) / fs) + 1;
        cumulativeDistance = [0; cumsum(hypot(diff(E), diff(N)))];
        sampleDistance = linspace(0, cumulativeDistance(end), numberOfPoints);
    % Interpolate each direction to that sampleDistance
        interpE = interp1(cumulativeDistance, E, sampleDistance, method);
        interpN = interp1(cumulativeDistance, N, sampleDistance, method);
end