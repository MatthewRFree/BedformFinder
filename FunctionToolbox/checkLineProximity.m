function isProximal = checkLineProximity(targetE,targetN,lineE,lineN,threshold)
    distanceSquared = (lineE - targetE).^2 + (lineN - targetN).^2;
    [minDistanceSquared, ~] = min(distanceSquared);

    if sqrt(minDistanceSquared) > threshold
        isProximal = false;
    else
        isProximal = true;
    end
end