function plotLengthRelation(D)
    flowdepths = arrayfun(@(x) mean(x.h),D);
    lengths = arrayfun(@(x) mean(x.L),D);
    
    figure("Name","Length vs Flow Depth")
        x = linspace(0, 500, 10000);
        y2 = 5.22*x.^0.95;
        y3 = 1.62*x.^0.95;
        y4 = 16.83*x.^0.95;
        
        % B&V Fit
        semilogy(x, y2, '-k')
        hold on

        % B&V 90%
        semilogy(x, y4, '--k', "HandleVisibility", "off")
        semilogy(x, y3, '--k')

        scatter(flowdepths, lengths, 25, [0.2, 0.2, 0.2], "filled")
        ylabel("Mean Bedform Length, ⟨L⟩ (m)")
        xlabel("Mean Flow Depth, ⟨h⟩ (m)")
        offset = 0.75;
        yl = [min(lengths), max(lengths)];
        xl = [min(flowdepths), max(flowdepths)];
        ylim(yl .* [10^(-offset), 10^(offset)])
        xlim(xl .* [10^(-offset), 10^(offset)])
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')    
        grid
        box on;
end