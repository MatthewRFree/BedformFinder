function plotSteepnessRelation(D)
    flowdepths = arrayfun(@(x) mean(x.h),D);
    steepness = arrayfun(@(x) mean(x.H ./ x.L), D);
    
    figure("Name","Steepness vs Flow Depth")
        scatter(flowdepths, steepness, 25, [0.2, 0.2, 0.2], "filled")
        ylabel("Mean Bedform Steepness, ⟨H/L⟩")
        xlabel("Mean Flow Depth, ⟨h⟩ (m)")
        offset = 0.75;
        yl = [min(steepness), max(steepness)];
        xl = [min(flowdepths), max(flowdepths)];
        ylim(yl .* [10^(-offset), 10^(offset)])
        xlim(xl .* [10^(-offset), 10^(offset)])
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')    
        grid
        box on;
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end