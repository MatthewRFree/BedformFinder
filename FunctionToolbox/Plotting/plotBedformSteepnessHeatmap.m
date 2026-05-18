function plotBedformSteepnessHeatmap(D)
    X = D.RawData.X;
    Y = D.RawData.Y;

    figure("Name","Bedform Steepness Heatmap")
        heatMap(cell2mat(D.ProfileEastingPeak(:)),cell2mat(D.ProfileNorthingPeak(:)),D.H./D.L,500, X, Y);
        grid
        c = colorbar;
        c.Label.String = 'Bedform Steepness, H/L (-)';
        colormap("turbo")
        xlim([min(X), max(X)])
        ylim([min(Y), max(Y)])
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end