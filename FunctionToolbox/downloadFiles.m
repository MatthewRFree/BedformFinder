function message = downloadFiles(app, url, destDataDir, crsString)
    message = downloadAndExtractXYZAsCSV(app, url, destDataDir, crsString);
end

function tf = isCrossSection(x, y, gridSize, minimumDensity, densityCoverage)

    if nargin < 3, gridSize = 100; end
    if nargin < 4, minimumDensity = 100; end
    if nargin < 5, densityCoverage = 0.20; end

    xi = discretize(x, min(x):gridSize:(max(x)+gridSize));
    yi = discretize(y, min(y):gridSize:(max(y)+gridSize));

    valid = ~isnan(xi) & ~isnan(yi);
    counts = accumarray([xi(valid), yi(valid)], 1);

    occupiedCells = nnz(counts);
    denseCells = nnz(counts >= minimumDensity);

    tf = denseCells / occupiedCells < densityCoverage;
end

function [Xnew, Ynew] = reprojectXYZ(sourceCRS, destinationEPSG, X, Y)

    sourceEPSG = getEPSGFromString(sourceCRS);

    if isempty(sourceEPSG)
        Xnew = X;
        Ynew = Y;
        updateeHydroText(app,"&nbsp;&nbsp;&nbsp;&nbsp;Warning: Unrecognized CRS, skipping data projection.")
        return
    end

    src = projcrs(sourceEPSG);
    dst = projcrs(destinationEPSG);

    [lat, lon] = projinv(src, X, Y);
    [Xnew, Ynew] = projfwd(dst, lat, lon);
end

function rawData = downloadZipToMemory(app, url)

    rawData = [];
    updateeHydroText(app,"&nbsp;&nbsp;&nbsp;&nbsp;Downloading ZIP file. (uninterruptible)");

    maxTries = 3;

    for attempt = 1:maxTries

        if ~waitIfPaused(app)
            return
        end

        try
            opts = weboptions('Timeout',30,'ContentType','raw');
            rawData = webread(url, opts);

            if numel(rawData) < 1000
                error("File too small");
            end

            return

        catch
            if attempt == maxTries
                updateeHydroText(app,"Error: Download failed.");
                return
            end
            pause(1);
        end
    end
end

function mustContinue = waitIfPaused(app)

    mustContinue = true;

    while ~app.downloadLoopRunning
        pause(0.1);
        drawnow;
        if app.downloadLoopCancel
            mustContinue = false;
            return
        end
    end

    if app.downloadLoopCancel
        mustContinue = false;
    end
end

function message = downloadAndExtractXYZAsCSV(app, url, destDataDir, crsString, minimumByteSize)

    message = " ";

    if nargin < 5
        minimumByteSize = 1000 * 1024;
    end

    rawData = downloadZipToMemory(app, url);

    if isempty(rawData)
        return
    end

    try
        byteStream = java.io.ByteArrayInputStream(rawData);
        zipStream  = java.util.zip.ZipInputStream(byteStream);

        updateeHydroText(app,"&nbsp;&nbsp;&nbsp;&nbsp;Scanning ZIP for data.");

        entry = zipStream.getNextEntry();
        xyzFound = false;

        while ~isempty(entry)

            if ~waitIfPaused(app)
                zipStream.close();
                return
            end

            name = char(entry.getName());

            if endsWith(lower(name),'a.xyz')

                if entry.getSize() < minimumByteSize
                    message = "Skipped: Too small.";
                    zipStream.close();
                    return
                end

                xyzFound = true;

                [X,Y,Z] = readXYZFromStream(app, zipStream);

                break
            end

            entry = zipStream.getNextEntry();
        end

        zipStream.close();

        if ~xyzFound
            message = "Skipped: No .xyz files found.";
            return
        end

        if isempty(X)
            message = "Skipped: No float data.";
            return
        end

        if isCrossSection(X, Y)
            message = "Skipped: Cross section.";
            return
        end

        [Xp, Yp] = reprojectXYZ(crsString, 5070, X, Y);

        [~, baseName, ~] = fileparts(name);
        csvName = baseName + ".csv";

        dataOut = [Xp, Yp, Z];
        writematrix(dataOut, fullfile(destDataDir, csvName), 'Delimiter',' ');

        message = "Saved.";

    catch ME
        message = "Error: " + ME.message;
    end
end

function [X,Y,Z] = readXYZFromStream(app, zipStream)
    updateeHydroText(app,"&nbsp;&nbsp;&nbsp;&nbsp;Reading file.");

    scanner = java.util.Scanner(zipStream, 'UTF-8');
    scanner.useDelimiter('\Z');
    txt = char(scanner.next());
    scanner.close();
    
    if ~waitIfPaused(app)
        return
    end
    
    lines = strsplit(txt, newline);

    block = 1e6;
    X = zeros(block,1);
    Y = zeros(block,1);
    Z = zeros(block,1);
    k = 0;
    
    for i = 1:numel(lines)
        if mod(i,10000) == 0
            if ~waitIfPaused(app)
                return
            end
        end
    
        nums = sscanf(lines{i}, '%f %f %f');
        if numel(nums) == 3
            k = k + 1;
            if k > numel(X)
                X(end+block) = 0;
                Y(end+block) = 0;
                Z(end+block) = 0;
            end
            X(k) = nums(1);
            Y(k) = nums(2);
            Z(k) = nums(3);
        end
    end
    
    X = X(1:k);
    Y = Y(1:k);
    Z = Z(1:k);
end