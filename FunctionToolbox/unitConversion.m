function x = unitConversion(x,currentUnit,convertedUnit)
% UNITCONVERSION converts units for a given vector
%   UNITCONVERSION allows for standardized precise conversion between units
%   such as feet, miles, meters, and kilometers.
%
%   X = UNITCONVERSION(X,CURRENTUNIT,CONVERTEDUNIT) Takes in the vector of
%   numeric data X and the string values for CURRENTUNIT and CONVERTEDUNIT
%   to convert from known units to the desired units.
%
%   Other Functions Referenced:
%       error(...), unitConversion(...)
%
%
%   -- Matthew Free 10/2025 --


%% Arguments
    arguments
        x 
        currentUnit {mustBeMember(currentUnit,["mi","km","m","US survey ft"])}
        convertedUnit {mustBeMember(convertedUnit,["mi","km","m","US survey ft"])}
    end

%% Converts Units
    if currentUnit == "m"
        switch convertedUnit
            case "mi"
                x = x*(1/1609.344);
            case "km"
                x = x*(1/1000);
            case "US survey ft"
                x = x*(3937/1200);
            case "m"
                return
            otherwise
                error("Unit not suported")
        end
    else
        switch currentUnit
            case "mi"
                x = unitConversion(x*(1609.344),"m",convertedUnit);
            case "km"
                x = unitConversion(x*(1000),"m",convertedUnit);
            case "US survey ft"
                x = unitConversion(x*(1200/3937),"m",convertedUnit);
            otherwise
                error("Unit not suported")
        end
    end
end