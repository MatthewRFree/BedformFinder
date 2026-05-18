function plotBedformHeightHeatmap(D)
    X = D.RawData.X;
    Y = D.RawData.Y;

    figure("Name","Bedform Height Heatmap")
        heatMap(cell2mat(D.ProfileEastingPeak(:)),cell2mat(D.ProfileNorthingPeak(:)),D.H,500, X, Y);
        grid
        c = colorbar;
        c.Label.String = 'Bedform Height, H (m)';
        colormap("turbo")
        xlim([min(X), max(X)])
        ylim([min(Y), max(Y)])
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end