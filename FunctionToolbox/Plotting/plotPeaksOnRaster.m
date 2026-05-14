function plotPeaksOnRaster(D, ax)

    if nargin < 2 || isempty(ax)
        f = figure("Name","Peaks on Raster");
        ax = axes(f);
    else
        cla(ax);
    end

    hold(ax, 'on');

    X = D.RawData.X;
    Y = D.RawData.Y;
    Z = -D.RawData.Z;

    rng(1)
    samplePoints = randperm(numel(X), round(0.05*numel(X)));
    Xsub = X(samplePoints);
    Ysub = Y(samplePoints);

    [~, nearestNeighbor] = knnsearch([X(:), Y(:)], [Xsub, Ysub], "K", 2);
    gridspacing = mean(nearestNeighbor(:,2));

    [Zg, xlims, ylims] = pc2dem( ...
        pointCloud([X(:) Y(:) Z(:)]), ...
        gridspacing, ...
        "CornerFillMethod","idw", ...
        "SearchRadius",sqrt(2)*gridspacing);

    xvec = xlims(1):gridspacing:xlims(2);
    yvec = ylims(1):gridspacing:ylims(2);

    [Xg, Yg] = meshgrid(xvec, yvec);

    diffZ = Zg - smoothdata2(Zg, 'movmean', 0.75*ceil(mean(D.L)));

    h = pcolor(ax, Xg, Yg, diffZ);
    shading(ax, 'interp');
    set(h, 'EdgeColor', 'none');

    axis(ax, 'equal');
    axis(ax, 'tight');

    duneEastingPeaks = cell2mat(D.ProfileEastingPeak(~cellfun(@isempty,D.ProfileEastingPeak)));
    duneNorthingPeaks = cell2mat(D.ProfileNorthingPeak(~cellfun(@isempty,D.ProfileNorthingPeak)));

    dotScale = 1e3 / max([range(X), range(Y)]);

    scatter(ax, duneEastingPeaks, duneNorthingPeaks, ...
        11*dotScale, "w", 'filled', 'MarkerFaceAlpha', 0.9);

    scatter(ax, duneEastingPeaks, duneNorthingPeaks, ...
        8*dotScale, [0.15 0.5 0.05], 'filled', 'MarkerFaceAlpha', 0.9);

    xlabel(ax, 'Easting');
    ylabel(ax, 'Northing');

    daspect(ax, [1 1 1]);

    c = colorbar(ax);
    c.Label.String = '\Deltaz';

    cstd = std(Zg(:), 'omitnan');

    colormap(ax, getColor("rwb"));
    clim(ax, [-0.5*cstd 0.5*cstd]);

end

function color = getColor(s)
    n = 256;
    if s == "rwb"
        whiteBandRatio = 0.01;
        colorCurvePower = 0.6;

        numberOfWhiteCells = round(n * whiteBandRatio);
        numberOnEachSide = round((n - numberOfWhiteCells) / 2);
        x = linspace(0, 1, numberOnEachSide)';
        equation = x.^colorCurvePower;

        r1 = equation;
        g1 = equation;
        b1 = ones(numberOnEachSide, 1);

        r2 = ones(numberOnEachSide, 1);
        g2 = flip(equation);
        b2 = flip(equation);

        rW = ones(numberOfWhiteCells, 1);
        gW = ones(numberOfWhiteCells, 1);
        bW = ones(numberOfWhiteCells, 1);

        color = [r1 g1 b1; rW gW bW; r2 g2 b2];
    elseif s == "rb"
        r = linspace(0, 1, n)';
        g = zeros(n, 1);
        b = linspace(1, 0, n)';

        color = [r g b];
    else
        color = 'turbo';
    end
end