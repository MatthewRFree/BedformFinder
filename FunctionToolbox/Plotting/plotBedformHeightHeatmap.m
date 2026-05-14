function plotBedformHeightHeatmap(D)
    X = D.RawData.X;
    Y = D.RawData.Y;

    figure("Name","Bedform Height Heatmap")
        heatMap(cell2mat(D.ProfileEastingPeak(:)),cell2mat(D.ProfileNorthingPeak(:)),D.H,500, X, Y);
        grid
        c = colorbar;
        c.Label.String = 'Height';
        colormap("turbo")
end