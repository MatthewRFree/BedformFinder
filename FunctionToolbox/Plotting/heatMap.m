function heatMap(Eastings, Northings, Color, gridspacing, xBoundary, yBoundary)

    arguments
        Eastings double
        Northings double
        Color double
        gridspacing double {mustBeInRange(gridspacing, 1, 1000)} = 500
        xBoundary = [];
        yBoundary = [];
    end

%% Interpolate Data

    % Create evenly spaced vectors and create a grid
    xlinspace = linspace(min(Eastings), max(Eastings), gridspacing);
    ylinspace = linspace(min(Northings), max(Northings), gridspacing);
    [grid_X, grid_Y] = meshgrid(xlinspace, ylinspace);

    % Create scatteredInterpolant Object, Natural Interpolation, No Extrapolation
    scatteredInterpolantC = scatteredInterpolant(Eastings, Northings, Color, 'natural', 'none');

    % Apply the scatteredInterpolant to the grid
    interpolatedC = scatteredInterpolantC(grid_X, grid_Y);

    % Use alphaShape to capture external edges and internal holes
    shp = alphaShape(Eastings, Northings, 100);
    insideMask = inShape(shp, grid_X, grid_Y);

    % Mask out invalid interpolated values
    interpolatedC(~insideMask) = NaN;

%% Plot Data
    imagesc(xlinspace, ylinspace, interpolatedC);
    hold on;
    axis xy equal tight
    daspect([1,1,1])
    set(gca, 'Color', 'w');
    hImg = findobj(gca, 'Type', 'Image');
    set(hImg, 'AlphaData', ~isnan(interpolatedC));
    clim([prctile(Color, 2.5), prctile(Color, 97.5)])
    xlabel('Eastings (m)');
    ylabel('Northings (m)');
    
    if (~(isempty(xBoundary) || isempty(yBoundary)))
        boundaryIndex = boundary(xBoundary, yBoundary, 0.5);
        plot(xBoundary(boundaryIndex), yBoundary(boundaryIndex), 'k-', 'LineWidth', 2);
    end
end