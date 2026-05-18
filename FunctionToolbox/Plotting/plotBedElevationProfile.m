function plotBedElevationProfile(D,index)
    figure("Name", "Bed Elevation Profile")
        S = unitConversion(D.ProfileDuneInfo.S{index},"mi","m");
        Z = unitConversion(D.ProfileDuneInfo.Z{index},"US survey ft","m");
        plot(S,Z, '-k')
        hold on;
        markerSize = 25;
        scatter(S(D.ProfileDuneInfo.PeakIndices{index}),Z(D.ProfileDuneInfo.PeakIndices{index}),markerSize,"red","filled")
        scatter(S(D.ProfileDuneInfo.TroughIndices{index}),Z(D.ProfileDuneInfo.TroughIndices{index}),markerSize,"blue","filled")
        xlabel("Longitudinal Position (m)")
        ylabel("Vertical Position (m)")
        offset = 200;
        xlim([nanmean(S)-offset, nanmean(S)+offset])
        grid on   
        box on;
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end