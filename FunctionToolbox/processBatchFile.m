function message = processBatchFile(params, dataFileName, app)
    message = [];
    dataFileLoc = fullfile(params.dataDirectoryLoc, string(dataFileName));

    try
        [~, filename, ext] = fileparts(dataFileLoc);
        if strcmpi(ext, '.mat')
            dataFile = loadMatAsTable(dataFileLoc);
        else
            dataFile = readtable(dataFileLoc);
        end

        if width(dataFile) < 3 || ~all(varfun(@isnumeric, dataFile, 'OutputFormat','uniform'))
            message = sprintf("Error: Data file must contain at least 3 numeric columns (X,Y,Z).");
            if nargin > 2
                app.updateBatchText(message)
            end
            return
        end
    catch
        message = sprintf("Error: Invalid File - %s.", dataFileName);
        if nargin > 2
            app.updateBatchText(message)
        end
        return
    end

    X = dataFile{:,1};  Y = dataFile{:,2};  Z = dataFile{:,3};
    E = params.riverLine{:,1}; N = params.riverLine{:,2};

    [dataFileCRS, X, Y] = chooseUTMCRS(params.dataEPSG, X, Y);

    srcCRS = projcrs(params.lineEPSG);
    [lat, lon] = projinv(srcCRS, E, N);
    [E, N] = projfwd(dataFileCRS, lat, lon);

    [center, radius] = medianCenterCircle(X, Y);

    if ~checkLineProximity(center(1), center(2), E, N, 800)
        message = sprintf("Error: River line is not in proximity to data (>800 meters).");
        if nargin > 2
            app.updateBatchText(message)
        end
        return
    end

    if params.verticalUnits == "US survey feet"
        Z = unitConversion(Z, "US survey ft", "m");
    end
    if params.verticalType == "Elevation"
        Z = -Z;
    end

    try
        [right, left] = getCopyRecommendation(E, N, X, Y, params.offset);

        BEPs = getInterpolationLines(E, N, center, radius, right, left, params.sampleSpacing, params.offset);
        BEPs = interpolateShape(X, Y, Z, BEPs);
        BEPs = getLongitudinalProfileData(BEPs);

        Data = getProfileData(string(filename), BEPs, params.riverLine, params.threshold, unitConversion(params.prominence, "m", "US survey ft"));
        Data.RawData.X = X;
        Data.RawData.Y = Y;
        Data.RawData.Z = Z;
        Data.Parameters.CoordinateReferenceSystem = dataFileCRS;

        file = fullfile(params.root, string(Data.Filename) + params.fileExt);

        if params.fileExt == ".json"
            jsonStr = jsonencode(Data);
            fid = fopen(file, "w", "n", "UTF-8");
            if fid == -1
                message = sprintf("Error: Could not open %s.", string(file));
                if nargin > 2
                    app.updateBatchText(message)
                end
                return
            end
            cleanupObj = onCleanup(@() fclose(fid));
            fwrite(fid, jsonStr, "char");
        elseif params.fileExt == ".hdf5"
            struct2h5(file, Data);
        else
            save(file, "Data")
        end

    catch ME
        message = sprintf("Error: Could not process %s. %s", string(filename), ME.message);
        if nargin > 2
            app.updateBatchText(message)
        end
    end
end