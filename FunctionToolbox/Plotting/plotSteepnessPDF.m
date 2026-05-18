function plotSteepnessPDF(D)
    figure("Name","Steepness PDF")
        histogram(D.H./D.L,25,'Normalization', 'pdf')
        xlabel("Bedform Steepness, H/L (-)")
        ylabel("PDF")
        hold on

        pd = fitdist(D.H./D.L, 'Lognormal');
        x = linspace(0, max(D.H./D.L), 1000);
        y = pdf(pd, x);
        plot(x, y, 'LineWidth', 2);
        legend('Data', 'Lognormal PDF');
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end