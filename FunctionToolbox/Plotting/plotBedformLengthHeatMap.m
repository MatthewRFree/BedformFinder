function plotBedformLengthHeatMap(D)
    X = D.RawData.X;
    Y = D.RawData.Y;

    figure("Name","Bedform Length Heatmap")
        heatMap(cell2mat(D.ProfileEastingPeak(:)),cell2mat(D.ProfileNorthingPeak(:)),D.L,500, X, Y);
        grid
        c = colorbar;
        c.Label.String = 'Length';
        colormap("turbo")
end