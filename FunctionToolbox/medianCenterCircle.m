function [center, radius] = medianCenterCircle(E, N)

arguments
    E
    N
end

    % Remove NaNs
    valid = isfinite(E) & isfinite(N);
    E = E(valid);
    N = N(valid);
    
    % Compute mean center
    xCenter = median(E);
    yCenter = median(N);
    
    % Compute maximum distance from center
    r = max(hypot(E - xCenter, N - yCenter));
    
    % Add offset
    center = [xCenter, yCenter];
    radius = sqrt(2)*r;
end