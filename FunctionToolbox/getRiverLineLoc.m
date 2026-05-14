function riverLineLoc = getRiverLineLoc(locationString)
    switch locationString
        case "Mississippi"
            riverLineLoc = "";
        case "Missouri"
            riverLineLoc = ".\App Dependancies\RiverLines\MissouriRiverSailingLine.mat";
        case "Arkansas"
            riverLineLoc = "";
        case "Ohio"
            riverLineLoc = "";
        case "Illinois"
            riverLineLoc = "";
        case "Auto"
            riverLineLoc = "";
        otherwise
            riverLineLoc = "";
    end
end