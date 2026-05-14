function [srcName, srcProjection, urls] = fetchInfo(startDate, endDate, boundingBox, river, numberOfSlices)
    if nargin < 5
        numberOfSlices = 3;
    end

    riverCode = "";

    switch river
        case "Mississippi (UM)"
            riverCode = "UM";
        case "Mississippi (LM)"
            riverCode = "LM";
        case "Mississippi (MS)"
            riverCode = "MS";
        case "Mississippi (MD)"
            riverCode = "MD";
        case "Missouri (MO)"
            riverCode = "MO";
        case "Arkansas (AR)"
            riverCode = "AR";
        case "Ohio (OH)"
            riverCode = "OH";
        case "Illinois (IL)"
            riverCode = "IL";
        otherwise
            riverCode = river;
    end

    allFeatures = struct([]);

    numberOfYears = 2;
    currentStart = startDate;
    while currentStart < endDate
        
        currentEnd = min(currentStart + calyears(numberOfYears) - days(1), endDate);
    
        features = queryBoundingBox(currentStart, currentEnd, boundingBox, numberOfSlices);

        if ~isempty(features)
            allFeatures = [allFeatures; features(:)];
        end

        currentStart = currentStart + calyears(numberOfYears);
    end
    
    if ~isempty(allFeatures)
        attrs = [allFeatures.attributes];
        urls = {attrs.sourcedatalocation}.';
        srcProjection = {attrs.sourceprojection}.';
        srcName = {attrs.surveyjobidpk}.';
        
        [srcName, idx] = unique(srcName);
        srcProjection = srcProjection(idx);
        urls = urls(idx);

        for i = 1:numel(srcName)
            temp = split(srcName{i},"_");
            srcCode(i) = string(temp{1});
        end

        idx = find(srcCode == riverCode);
        srcName = srcName(idx);
        srcProjection = srcProjection(idx);
        urls = urls(idx);

    else
        urls = [];
        srcProjection = [];
        srcName = [];
    end
end

function allFeatures = queryBoundingBox(startDate, endDate, boundingBox, numberOfSlices)
    url = "https://services7.arcgis.com/n1YM8pTrFmm7L4hs/arcgis/rest/services/eHydro_Survey_Data/FeatureServer/0/query";

    xmin = boundingBox(1);
    ymin = boundingBox(2);
    xmax = boundingBox(3);
    ymax = boundingBox(4);

    diffX = xmax-xmin;
    diffY = ymax-ymin;

    if diffX > diffY
        numberOfSlicesY = numberOfSlices;
        numberOfSlicesX = ceil(diffX/diffY)*numberOfSlices;
    else
        numberOfSlicesX = numberOfSlices;
        numberOfSlicesY = ceil(diffY/diffX)*numberOfSlices;
    end

    latitudeStep = diffY / numberOfSlicesY;
    longitudeStep = diffX / numberOfSlicesX;
    allFeatures = struct([]);

    options = weboptions("ContentType","json", "Timeout",60,"CertificateFilename",'default');

    for i = 1:numberOfSlicesY
        for j = 1:numberOfSlicesX
            sliceymin = ymin + (i-1)*latitudeStep;
            sliceymax = ymin + i*latitudeStep;
            slicexmin = xmin + (j-1)*longitudeStep;
            slicexmax = xmin + j*longitudeStep;
    
            dateString = sprintf("dateuploaded >= timestamp '%s' AND dateuploaded <= timestamp '%s'", startDate, endDate);
    
            locationString = sprintf("%f,%f,%f,%f", slicexmin, sliceymin, slicexmax, sliceymax);
    
            maxRetries = 5;
            for attempt = 1:maxRetries
                try
                    data = webread( ...
                    url, ...
                    "f","json", ...
                    "where", dateString, ...
                    "outFields","sourcedatalocation,sourceprojection,surveyjobidpk", ...
                    "returnGeometry","false", ...
                    "geometry", locationString, ...
                    "geometryType","esriGeometryEnvelope", ...
                    "inSR","4326", ...
                    "spatialRel","esriSpatialRelIntersects", ...
                    "resultRecordCount","2000", ...
                    options);
                    break;
                catch ME
                    warning("Attempt %d failed: %s", attempt, ME.message);
                    pause(0.1);
                    if attempt == maxRetries
                        error("Failed after %d attempts", maxRetries);
                    end
                end
            end
    
            if isfield(data, "features")
                features = data.features;
            else
                features = struct([]);
            end
    
            if numel(features) == 2000
                features = queryBoundingBox( ...
                    startDate, endDate, ...
                    [slicexmin, sliceymin, slicexmax, sliceymax], numberOfSlices);
            end
    
            if ~isempty(features)
                allFeatures = [allFeatures; features(:)];
            end
        end
    end
end