function S = h52struct(filename)
% H52STRUCT  Recursively reconstructs MATLAB structures from an HDF5 file
%
%   S = H52STRUCT(FILENAME) reads an HDF5 file created using STRUCT2H5 and
%   reconstructs the original MATLAB structure. Nested structs,
%   structure arrays, cell arrays, and other MATLAB datatypes are
%   restored automatically using stored metadata and attributes.
%
%   Other Functions Referenced:
%       H5F.open, H5D.open, H5D.read, H5G.open, H5G.get_num_objs,
%       H5G.get_objname_by_idx, H5A.open, H5A.read, H5T.close,
%       strsplit, reshape, prod, struct, cell, logical, datetime,
%       projcrs, char, string, deblank
%
%
%   -- Matthew Free 04/2026 --

%% Open HDF5 file
    fid = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
    
    try
        S = readGroup('/');
    catch e
        H5F.close(fid);
        rethrow(e);
    end
    
    H5F.close(fid);

%% Begin Reading Groups
    function outputStructure = readGroup(path)
        % Get field order from group attribute if it exists
        orderedFields = getGroupAttr(path, 'MATLAB_fields');
        if ~isempty(orderedFields)
            names = strsplit(orderedFields, '|');
        else
            names = getChildNames(path);
            names = names(~strcmp(names, '_meta'));
        end

        % Check for struct array
        allNames = getChildNames(path);
        if ismember('_meta', allNames)
            cls = getAttr(joinPath(path, '_meta'), 'MATLAB_class');
            if strcmp(cls, 'struct_array')
                sz  = double(readRaw(joinPath(path, '_meta')))';
                outputStructure = readStructArray(path, sz);
                return
            end
        end

        outputStructure = struct();
        for i = 1:numel(names)
            name     = names{i};
            fullPath = joinPath(path, name);

            if isGroup(fullPath)
                childNames = getChildNames(fullPath);
                if ismember('_meta', childNames)
                    cls = getAttr(joinPath(fullPath, '_meta'), 'MATLAB_class');
                    if strcmp(cls, 'cell')
                        sz = double(readRaw(joinPath(fullPath, '_meta')))';
                        outputStructure.(name) = readCell(fullPath, sz);
                        continue
                    elseif strcmp(cls, 'struct_array')
                        sz = double(readRaw(joinPath(fullPath, '_meta')))';
                        outputStructure.(name) = readStructArray(fullPath, sz);
                        continue
                    end
                end
                outputStructure.(name) = readGroup(fullPath);
            else
                outputStructure.(name) = readValue(fullPath);
            end
        end
    end

%% Read an Array of Structures
    function out = readStructArray(path, sz)
        n   = prod(sz);
        tmp = cell(n, 1);
        for i = 1:n
            tmp{i} = readGroup(sprintf('%s/struct_%04d', path, i));
        end
        out = reshape([tmp{:}], sz);
    end

%% Read a cell array
    function out = readCell(path, sz)
        n   = prod(sz);
        out = cell(sz);
        for i = 1:n
            out{i} = readValue(sprintf('%s/cell_%04d', path, i));
        end
    end

%% Read in values
    function val = readValue(path)
        cls     = getAttr(path, 'MATLAB_class');
        isEmpty = getAttr(path, 'MATLAB_empty');
        isEmpty = isequal(isEmpty, true) || isequal(isEmpty, uint8(1));

        switch cls
            case 'logical'
                val = logical(readRaw(path));

            case 'char'
                if isEmpty
                    val = "";
                else
                    val = string(char(readRaw(path)'));
                end

            case 'datetime'
                if isEmpty
                    val = datetime.empty;
                else
                    val = datetime(deblank(char(readRaw(path)')), ...
                        'InputFormat', 'dd-MMM-yyyy', 'Format', 'dd-MMM-yyyy');
                end

            case 'projcrs'
                val = projcrs(deblank(char(readRaw(path)')));

            otherwise
                val = readRaw(path);
        end
    end

%% Read raw data
    function raw = readRaw(path)
        did = H5D.open(fid, path);
        raw = H5D.read(did, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
        H5D.close(did);
        if isnumeric(raw) && ~isscalar(raw) && isvector(raw)
            raw = raw(:);
        end
    end

%% Get Attribute
    function cls = getAttr(path, attrName)
        % Read attribute from a dataset
        cls = '';
        try
            did = H5D.open(fid, path);
            cls = readAttrFromId(did, attrName);
            H5D.close(did);
        catch
        end
    end

%% Get group Attributes
    function val = getGroupAttr(path, attrName)
        % Read attribute from a group
        val = '';
        try
            gid = H5G.open(fid, path);
            val = readAttrFromId(gid, attrName);
            H5G.close(gid);
        catch
        end
    end

%% Read Attributes
    function cls = readAttrFromId(id, attrName)
        cls = '';
        try
            aid = H5A.open(id, attrName);
            tid = H5A.get_type(aid);
            raw = H5A.read(aid, tid);
            H5T.close(tid);
            H5A.close(aid);

            if ischar(raw)
                cls = strtrim(raw(raw ~= 0)');
            elseif islogical(raw) || (isnumeric(raw) && isscalar(raw))
                cls = raw;
            elseif isnumeric(raw)
                cls = strtrim(char(raw(raw ~= 0))');
            end
        catch
        end
    end

%% Check if Group
    function tf = isGroup(path)
        tf = false;
        try
            gid = H5G.open(fid, path);
            H5G.close(gid);
            tf = true;
        catch
        end
    end

%% Get Child Names from the object
    function names = getChildNames(path)
        names = {};
        try
            gid = H5G.open(fid, path);
            n   = H5G.get_num_objs(gid);
            for i = 0:n-1
                names{end+1} = H5G.get_objname_by_idx(gid, i); %#ok<AGROW>
            end
            H5G.close(gid);
        catch
        end
    end

%% Join Paths to recurse into the structure
    function p = joinPath(base, name)
        if isempty(base) || strcmp(base, '/')
            p = ['/' name];
        elseif base(end) == '/'
            p = [base name];
        else
            p = [base '/' name];
        end
    end

end