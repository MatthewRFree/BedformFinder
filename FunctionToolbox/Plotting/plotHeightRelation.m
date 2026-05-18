function plotHeightRelation(D)
    flowdepths = arrayfun(@(x) mean(x.h),D);
    heights = arrayfun(@(x) mean(x.H),D);
    
    figure("Name","Height vs Flow Depth")
        x = linspace(0, 500, 10000);
        y2 = 0.13*x.^0.94;
        y3 = 0.05*x.^0.94;
        y4 = 0.38*x.^0.94;
        
        % B&V Fit
        semilogy(x, y2, '-k')
        hold on

        % B&V 90%
        semilogy(x, y4, '--k', "HandleVisibility", "off")
        semilogy(x, y3, '--k')

        scatter(flowdepths, heights, 25, [0.2, 0.2, 0.2], "filled")
        ylabel("Mean Bedform Height, ⟨H⟩ (m)")
        xlabel("Mean Flow Depth, ⟨h⟩ (m)")
        offset = 0.75;
        yl = [min(heights), max(heights)];
        xl = [min(flowdepths), max(flowdepths)];
        ylim(yl .* [10^(-offset), 10^(offset)])
        xlim(xl .* [10^(-offset), 10^(offset)])
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')    
        grid
        box on;
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end