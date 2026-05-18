function plotHeightPDF(D)
    figure("Name","Height PDF")
        histogram(D.H,25,'Normalization', 'pdf')
        xlabel("Bedform Height, H (m)")
        ylabel("PDF")
        hold on

        pd = fitdist(D.H, 'Lognormal');
        x = linspace(0, max(D.H), 1000);
        y = pdf(pd, x);
        plot(x, y, 'LineWidth', 2);
        legend('Data', 'Lognormal PDF');
        set(findall(gcf,'-property','FontName'),'FontSize',20);
end