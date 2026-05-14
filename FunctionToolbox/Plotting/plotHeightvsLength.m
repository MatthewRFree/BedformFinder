function plotHeightvsLength(D)
    flowdepths = arrayfun(@(x) mean(x.h),D);
    lengths = arrayfun(@(x) mean(x.L),D);
    heights = arrayfun(@(x) mean(x.H),D);

    figure("Name","Dune Height vs Dune Length")
        x = linspace(0, 500, 10000);
        y = 0.0513*x.^0.7744;

        % B&V 2017
        plot(x,y,"--k")
        hold on

        scatter(lengths, heights, 25, flowdepths, "filled", "HandleVisibility","off")
        colormap("turbo")
        cb = colorbar;
        cb.Label.String ='Mean Flow Depth, ⟨h⟩ (m)';
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')
        xlabel("Mean Bedform Length, ⟨L⟩ (m)")
        ylabel("Mean Bedform Height, ⟨H⟩ (m)")
        offset = 0.75;
        yl = [min(heights), max(heights)];
        xl = [min(lengths), max(lengths)];
        ylim(yl .* [10^(-offset), 10^(offset)])
        xlim(xl .* [10^(-offset), 10^(offset)])
        grid on
        box on
end