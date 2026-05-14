function T = loadMatAsTable(file)
    S = load(file);
    feidlNames = fieldnames(S);

    for k = 1:numel(feidlNames)
        x = S.(feidlNames{k});

        % Case 1: already a table
        if istable(x)
            T = x;
            return
        end

        % Case 2: numeric matrix
        if isnumeric(x) && ismatrix(x)
            T = array2table(x);
            return
        end

        % Case 3: struct
        if isstruct(x)
            try
                T = struct2table(x);
                return
            catch
            end
        end
    end
    T = table();
end