function [numAbove, numBelow] = getCopyRecommendation(lineE,lineN, E, N, offset)

    valid = (lineE > min(E)) & (lineE < max(E)) & (lineN > min(N)) & (lineN < max(N));
    lineE = lineE(valid);
    lineN = lineN(valid);
    
    dE = gradient(lineE);
    dN = gradient(lineN);
    L = hypot(dE, dN);
    
    tangentE = dE ./ L;
    tangentN = dN ./ L;
    
    rightNormalE = tangentN;
    rightNormalN = -tangentE;
    leftNormalE = -tangentN;
    leftNormalN = tangentE;
    
    numberSamplePoints = round(0.01 * numel(E));
    rng(1)
    idx = randperm(numel(E), numberSamplePoints);
    Esub = E(idx);
    Nsub = N(idx);
    
    warning('off', 'MATLAB:polyshape:repairedBySimplify');
    
    shape = boundary(Esub, Nsub);
    shape = polyshape([Esub(shape),Nsub(shape)]);
    
    warning('on', 'MATLAB:polyshape:repairedBySimplify');
    
    initialInside = isinterior(shape, lineE, lineN);
    
    if any(initialInside)
        numAbove = 1;
        isInside = true;
    
        while isInside
            copyRightE = lineE + numAbove * offset * rightNormalE;
            copyRightN = lineN + numAbove * offset * rightNormalN;
            isInside = inShape(shape, copyRightE, copyRightN);
            numAbove = numAbove + 1;
        end
        
        numBelow = 1;
        isInside = true;
        
        while isInside
            copyLeftE = lineE + numBelow * offset * leftNormalE;
            copyLeftN = lineN + numBelow * offset * leftNormalN;
            isInside = inShape(shape, copyLeftE, copyLeftN);
            numBelow = numBelow + 1;
        end
    else
        medianE = median(Esub);
        medianN = median(Nsub);
        
        [~, closestLineIdx] = min(hypot(lineE - medianE, lineN - medianN));
        
        dirE = medianE - lineE(closestLineIdx);
        dirN = medianN - lineN(closestLineIdx);
        Ldir = hypot(dirE, dirN);
        dirE = dirE / Ldir;
        dirN = dirN / Ldir;
        
        dotRight = dot([dirE dirN], [rightNormalE(closestLineIdx) rightNormalN(closestLineIdx)]);
        dotLeft  = dot([dirE dirN], [leftNormalE(closestLineIdx) leftNormalN(closestLineIdx)]);
        
        if dotRight > 0
            numBelow = 0;
            numAbove = 1;
            isInside = true;
            
            minLines = ceil(Ldir / offset) + 1;
            
            while isInside || numAbove <= minLines
                copyRightE = lineE + numAbove * offset * rightNormalE;
                copyRightN = lineN + numAbove * offset * rightNormalN;
                isInside = inShape(shape, copyRightE, copyRightN);
                numAbove = numAbove + 1;
            end

        elseif dotLeft > 0
            numAbove = 0;
            numBelow = 1;
            isInside = true;
            
            minLines = ceil(Ldir / offset) + 1;
            
            while isInside || numBelow <= minLines
                copyLeftE = lineE + numBelow * offset * leftNormalE;
                copyLeftN = lineN + numBelow * offset * leftNormalN;
                isInside = inShape(shape, copyLeftE, copyLeftN);
                numBelow = numBelow + 1;
            end

        else
            numAbove = 1;
            isInside = true;
            
            minLines = ceil(Ldir / offset) + 1;
            
            while isInside || numAbove <= minLines
                copyRightE = lineE + numAbove * offset * rightNormalE;
                copyRightN = lineN + numAbove * offset * rightNormalN;
                isInside = inShape(shape, copyRightE, copyRightN);
                numAbove = numAbove + 1;
            end

            numBelow = 1;
            isInside = true;
            
            minLines = ceil(Ldir / offset) + 1;
            
            while isInside || numBelow <= minLines
                copyLeftE = lineE + numBelow * offset * leftNormalE;
                copyLeftN = lineN + numBelow * offset * leftNormalN;
                isInside = inShape(shape, copyLeftE, copyLeftN);
                numBelow = numBelow + 1;
            end
        end
    end
end

function isInside = inShape(shape, x, y)
    pointsInside = isinterior(shape, x, y);

    if any(pointsInside)
        isInside = true;
    else
        isInside = false;
    end
end
