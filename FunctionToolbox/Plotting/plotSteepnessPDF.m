function plotSteepnessPDF(D)
    figure("Name","Steepness PDF")
        histogram(D.H./D.L,25,'Normalization', 'pdf')
        title("Steepness Probability Density Plot")
        xlabel("Steepness, H/L")
        ylabel("Probability Density")
        hold on

        pd = fitdist(D.H./D.L, 'Lognormal');
        x = linspace(0, max(D.H./D.L), 1000);
        y = pdf(pd, x);
        plot(x, y, 'LineWidth', 2);
        legend('Data Histogram', 'Lognormal PDF');
end