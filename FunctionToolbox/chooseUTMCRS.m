function [dstCRS, X, Y] = chooseUTMCRS(inputEPSG, X, Y)
    srcCRS = projcrs(inputEPSG);
    [lat, lon] = projinv(srcCRS, X, Y);
    
    latCenter = mean(lat);
    lonCenter = mean(lon);
    
    zone = floor((lonCenter + 180)/6) + 1;
    
    if latCenter >= 0
        dstEPSG = 32600 + zone;
    else
        dstEPSG = 32700 + zone;
    end

    dstCRS = projcrs(dstEPSG);
    [X, Y] = projfwd(dstCRS,lat,lon);
end