function plotLengthPDF(D)
    figure("Name","Length PDF")
        histogram(D.L,25,'Normalization', 'pdf')
        title("Length Probability Density Plot")
        xlabel("Length, L (m)")
        ylabel("Probability Density")
        hold on

        pd = fitdist(D.L, 'Lognormal');
        x = linspace(0, max(D.L), 1000);
        y = pdf(pd, x);
        plot(x, y, 'LineWidth', 2);
        legend('Data Histogram', 'Lognormal PDF');
end