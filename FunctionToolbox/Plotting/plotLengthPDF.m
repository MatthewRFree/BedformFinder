function plotLengthPDF(D)
    figure("Name","Length PDF")
        histogram(D.L,25,'Normalization', 'pdf')
        xlabel("Bedform Length, L (m)")
        ylabel("PDF")
        hold on

        pd = fitdist(D.L, 'Lognormal');
        x = linspace(0, max(D.L), 1000);
        y = pdf(pd, x);
        plot(x, y, 'LineWidth', 2);
        legend('Data', 'Lognormal PDF');
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end