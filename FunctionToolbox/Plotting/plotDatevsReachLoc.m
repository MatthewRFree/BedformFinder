function plotDatevsReachLoc(D,units)
    switch units
        case "River Mile"
            locs = arrayfun(@(x) x.RiverMileStart,D);
        case "River Km"
            locs = arrayfun(@(x) x.RiverKmStart,D);
    end
    dates = arrayfun(@(x) x.Date, D);

    figure("Name","Date vs RKM")
        scatter(dates, locs, 25, [0.2, 0.2, 0.2],'filled');
        ylim([0,1.1*max(locs)])
        xlabel("Date")
        ylabel(units)
        grid on
        box on
end