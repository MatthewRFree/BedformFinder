function plotRawBathymetry(D, ax, X, Y, Z)
    if nargin < 2 || isempty(ax)
        f = figure("Name","Raw Bathymetry");
        ax = axes(f);
        X = D.RawData.X;
        Y = D.RawData.Y;
        Z = -D.RawData.Z;
    else
        cla(ax);
    end

    hold(ax, 'on');
    
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

    h = pcolor(ax, Xg, Yg, Zg);
    shading(ax, 'interp');
    set(h, 'EdgeColor', 'none');

    axis(ax, 'equal');
    axis(ax, 'tight');

    xlabel(ax, 'Easting (m)');
    ylabel(ax, 'Northing (m)');

    daspect(ax, [1 1 1]);
    xlim(ax, [min(X), max(X)])
    ylim(ax, [min(Y), max(Y)])

    c = colorbar(ax);
    c.Label.String = 'Depth, h (m) OR Elevation (m)';
    colormap(ax,"turbo");
    grid(ax,"on");
    set(findall(ax,'-property','FontName'),'FontSize',20);

    if nargin >= 2 && ~isempty(ax)
        offset = mean([0.2*(max(X)-min(X)), 0.2*(max(Y)-min(Y))]);
        textColor = ax.XColor;
        c.Color = textColor;
        c.Label.Color = textColor;
        xlim(ax, [min(X) - offset, max(X) + offset])
        ylim(ax, [min(Y) - offset, max(Y) + offset])
        disableDefaultInteractivity(ax)
    end
end