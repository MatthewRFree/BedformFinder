function struct2h5(filename, S)
% STRUCT2H5 Recursively writes a MATLAB structure to an HDF5 file
%
%   STRUCT2H5(FILENAME, S) converts a MATLAB struct (including nested
%   structs, cell arrays, into an HDF5 file representation.
%
%   Other Functions Referenced:
%       H5F.create, H5G.create, H5D.create, H5A.create, H5S.create,
%       H5T.copy, H5D.write, H5G.open, H5D.open, H5P.create,
%       strjoin, strsplit, fieldnames, matlab.lang.makeValidName,
%       isstruct, iscell, isnumeric, islogical, isnan, numel, size
%
%
%   -- Matthew Free 04/2026 --

%% Initialize file
    % Create file
        if isfile(filename)
            delete(filename);
        end
        fid = H5F.create(filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');

    % Track created HDF5 groups to avoid redundant creation
        createdGroups = containers.Map('KeyType','char','ValueType','logical');
        createdGroups('/') = true;

%% Begin file write
    try
    % Handle struct arrays vs single structs
        if isstruct(S) && numel(S) > 1
            writeStructArray(S, '/');
        else
            writeStruct(S, '/');
        end
    catch e
        H5F.close(fid);
        rethrow(e);
    end

    H5F.close(fid);

%% Handle Structs
    function writeStruct(s, group)
        % Get the field names
            fields = fieldnames(s);

        % Store field order
            setGroupAttr(group, 'MATLAB_fields', strjoin(fields, '|'));
        % loop through each field
            for i = 1:numel(fields)
                name = matlab.lang.makeValidName(fields{i});
                val  = s.(fields{i});
                path = [group name];
            % write based on type
                if isstruct(val)
                    if numel(val) > 1
                        writeStructArray(val, [path '/']);
                    else
                        writeStruct(val, [path '/']);
                    end
                elseif iscell(val)
                    writeCell(val, path);
                else
                    writeValue(val, path);
                end
            end
    end

%% Handle Struct Arrays
    function writeStructArray(arr, group)
        % Stores arrays of structs with indexing metadata
            ensureGroup(group);
            metaPath = [group '_meta'];
            writeRawNumeric(metaPath, double(size(arr)));
            setAttribute(metaPath, 'MATLAB_class', 'struct_array');
        % write each struct individually
            for i = 1:numel(arr)
                writeStruct(arr(i), sprintf('%sstruct_%04d/', group, i));
            end
    end

%% Write Cell Array
    function writeCell(C, basePath)
        ensureGroup(basePath);
        metaPath = [basePath '/_meta'];
        writeRawNumeric(metaPath, double(size(C)));
        setAttribute(metaPath, 'MATLAB_class', 'cell');
        for i = 1:numel(C)
            writeValue(C{i}, sprintf('%s/cell_%04d', basePath, i));
        end
    end

%% Write Values
    function writeValue(val, path)
        if isa(val, 'datetime')
            writeText(char(val), path);
            setAttribute(path, 'MATLAB_class', 'datetime');
            return
        elseif isa(val, 'projcrs')
            writeText(wktstring(val), path);
            setAttribute(path, 'MATLAB_class', 'projcrs');
            return
        end

        if islogical(val)
            ensureParentGroups(path);
            writeRawNumeric(path, uint8(val));
            setAttribute(path, 'MATLAB_class', 'logical');

        elseif isnumeric(val)
            ensureParentGroups(path);
            if isempty(val)
                writeRawNumeric(path, zeros(0, 0, class(val)));
            else
                writeRawNumeric(path, val);
            end

        elseif ischar(val) || isstring(val)
            writeText(val, path);
            setAttribute(path, 'MATLAB_class', 'char');

        else
            error('Unsupported type: %s at path %s', class(val), path);
        end
    end

%% Write Text
    function writeText(val, path)
        ensureParentGroups(path);
        data = uint8(char(val));
        if isempty(data)
            writeRawNumeric(path, uint8(0));
            setAttribute(path, 'MATLAB_empty', true);
        else
            writeRawNumeric(path, data);
        end
    end

%% Write Numeric Data
    function writeRawNumeric(path, data)
        tid = matlabTypeToH5(class(data));
        sz  = size(data);

        if any(sz == 0)
            sid = H5S.create('H5S_NULL');
        elseif isscalar(data)
            sid = H5S.create('H5S_SCALAR');
        else
            sid = H5S.create_simple(ndims(data), fliplr(sz), fliplr(sz));
        end

        did = H5D.create(fid, path, tid, sid, 'H5P_DEFAULT');
        if ~any(sz == 0)
            H5D.write(did, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
        end
        H5D.close(did);
        H5S.close(sid);
        H5T.close(tid);
    end

%% Create a New Data Attribute
    function setAttribute(path, name, value)
        % Set attribute on a dataset
        did = H5D.open(fid, path);
        writeAttrOnId(did, name, value);
        H5D.close(did);
    end

%% Set the Attribute to a group
    function setGroupAttr(path, name, value)
        % Set attribute on a group and ensure group exists first
        ensureGroup(path);
        gid = H5G.open(fid, path);
        writeAttrOnId(gid, name, value);
        H5G.close(gid);
    end

%% Write the Attribute on the group
    function writeAttrOnId(id, name, value)
        sid = H5S.create('H5S_SCALAR');
        if ischar(value) || isstring(value)
            value = char(value);
            tid = H5T.copy('H5T_C_S1');
            H5T.set_size(tid, max(1, numel(value)));
            aid = H5A.create(id, name, tid, sid, 'H5P_DEFAULT');
            H5A.write(aid, tid, value);
        elseif islogical(value)
            tid = H5T.copy('H5T_NATIVE_UINT8');
            aid = H5A.create(id, name, tid, sid, 'H5P_DEFAULT');
            H5A.write(aid, tid, uint8(value));
        else
            tid = matlabTypeToH5(class(value));
            aid = H5A.create(id, name, tid, sid, 'H5P_DEFAULT');
            H5A.write(aid, tid, value);
        end
        H5A.close(aid);
        H5T.close(tid);
        H5S.close(sid);
    end

%% Make sure group exists
    function ensureGroup(path)
        path = strtrim(path);
        if numel(path) > 1 && path(end) == '/'
            path = path(1:end-1);
        end
        if isempty(path), path = '/'; end
        if isKey(createdGroups, path), return, end
        ensureParentGroups([path '/placeholder']);
        createGroupSafe(path);
    end

%% Ensures parent exists or child
    function ensureParentGroups(path)
        parts = strsplit(path, '/');
        parts = parts(~cellfun('isempty', parts));
        for i = 1:numel(parts) - 1
            currPath = ['/' strjoin(parts(1:i), '/')];
            if isKey(createdGroups, currPath), continue, end
            createGroupSafe(currPath);
        end
    end

%% Creates group if no parent exists
    function createGroupSafe(path)
        if isKey(createdGroups, path), return, end
        try
            gcpl = H5P.create('H5P_GROUP_CREATE');
            gid  = H5G.create(fid, path, 'H5P_DEFAULT', gcpl, 'H5P_DEFAULT');
            H5G.close(gid);
            H5P.close(gcpl);
        catch
        end
        createdGroups(path) = true;
    end

%% Defines custom types
    function tid = matlabTypeToH5(cls)
        switch cls
            case 'double',  tid = H5T.copy('H5T_NATIVE_DOUBLE');
            case 'single',  tid = H5T.copy('H5T_NATIVE_FLOAT');
            case 'int8',    tid = H5T.copy('H5T_NATIVE_INT8');
            case 'int16',   tid = H5T.copy('H5T_NATIVE_INT16');
            case 'int32',   tid = H5T.copy('H5T_NATIVE_INT32');
            case 'int64',   tid = H5T.copy('H5T_NATIVE_INT64');
            case 'uint8',   tid = H5T.copy('H5T_NATIVE_UINT8');
            case 'uint16',  tid = H5T.copy('H5T_NATIVE_UINT16');
            case 'uint32',  tid = H5T.copy('H5T_NATIVE_UINT32');
            case 'uint64',  tid = H5T.copy('H5T_NATIVE_UINT64');
            otherwise,      tid = H5T.copy('H5T_NATIVE_DOUBLE');
        end
    end

end