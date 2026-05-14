function plotHeightPDF(D)
    figure("Name","Height PDF")
        histogram(D.H,25,'Normalization', 'pdf')
        title("Height Probability Density Plot")
        xlabel("Height, H (m)")
        ylabel("Probability Density")
        hold on

        pd = fitdist(D.H, 'Lognormal');
        x = linspace(0, max(D.H), 1000);
        y = pdf(pd, x);
        plot(x, y, 'LineWidth', 2);
        legend('Data Histogram', 'Lognormal PDF');
end