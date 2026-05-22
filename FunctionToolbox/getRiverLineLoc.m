function riverLineLoc = getRiverLineLoc(locationString)
    switch locationString
        case "Lower Mississippi (MD/MS/LM)"
            riverLineLoc = ".\App Dependancies\RiverLines\Lower_MississippiRiverSailingLine.mat";
        case "Upper Mississippi (UM)"
            riverLineLoc = ".\App Dependancies\RiverLines\Upper_MississippiRiverSailingLine.mat";
        case "Missouri (MO)"
            riverLineLoc = ".\App Dependancies\RiverLines\MissouriRiverSailingLine.mat";
        case "Arkansas (AR)"
            riverLineLoc = ".\App Dependancies\RiverLines\ArkansasRiverSailingLine.mat";
        case "Ohio (OH)"
            riverLineLoc = ".\App Dependancies\RiverLines\OhioRiverSailingLine.mat";
        case "Illinois (IL)"
            riverLineLoc = ".\App Dependancies\RiverLines\IllinoisRiverSailingLine.mat";
        otherwise
            riverLineLoc = "";
    end
end