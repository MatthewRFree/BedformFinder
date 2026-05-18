function plotRawBathymetry(D)
    figure("Name","Raw Bathymetry")
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
    
        h = pcolor(Xg, Yg, Zg);
        shading('interp');
        set(h, 'EdgeColor', 'none');
    
        axis('equal');
        axis('tight');

        xlabel('Easting (m)');
        ylabel('Northing (m)');
    
        daspect([1 1 1]);
    
        c = colorbar;
        c.Label.String = 'Depth, h (m)';
        colormap("turbo");
        grid on;
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end