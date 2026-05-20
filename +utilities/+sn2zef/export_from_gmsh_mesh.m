function [meshStruct, tissueTable] = export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)
%
% [meshStruct, tissueTable] = utilities.sn2zef.export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)
%
% Mesh-based export: loads a SimNIBS Gmsh mesh and tissue listing, then
% optionally writes per-compartment STL surfaces and the full mesh (MAT/HDF5).
% Use this when you have a .msh file and tissue table (e.g. from the charm
% pipeline). For the volume-based ZEF pipeline (final_tissues.nii.gz + LUT),
% use utilities.sn2zef.run instead.
%
% Inputs:
%
%   meshFile (1,1) string { mustBeFile }
%
% Path to a Gmsh .msh file (nodes, triangles, tetrahedra, region labels)
% produced by SimNIBS (e.g. charm pipeline).
%
%   tissueListingFile (1,1) string { mustBeFile }
%
% Path to the tissue listing file (label numbers, names, colors). Typically
% columns: #No., Label_Name:, R, G, B, Alpha.
%
%   kwargs.outputFolder (1,1) string = ""
%
% If non-empty, a timestamped subfolder is created here and filled with:
%   - One STL per compartment: <Name>.triangles.stl
%   - wholemesh.mat  (nodes, triangles, triangleLabels, tetra, tetraLabels)
%   - wholemesh.hdf5 (same structure)
%
%   kwargs.dateTimeFormat (1,1) string = "yyyy-MM-dd-HH-mm-ss-SSS"
%
% Format for the timestamp in the output folder name.
%
%   kwargs.labelNameStr (1,1) string = "Label_Name:"
%
% Column name in the tissue table for compartment names (for format changes).
%
%   kwargs.labelStr (1,1) string = "#No."
%
% Column name in the tissue table for numeric labels (for format changes).
%
%   kwargs.stlOutputFormat (1,1) string { mustBeMember(kwargs.stlOutputFormat, ["text", "binary"]) } = "binary"
%
% STL format: "binary" (compact) or "text" (ASCII).
%
%   kwargs.subjectName (1,1) string = ""
%
% Optional subject name included in the output folder name.
%
% Outputs:
%
%   meshStruct - Struct from meshLoadGmsh4: nodes, triangles, triangle_regions,
%                tetrahedra, tetrahedron_regions, and optional node_data/element_data.
%   tissueTable - Table of tissue labels, names, and colors from the listing file.
%
% Example:
%
%   [m, tbl] = utilities.sn2zef.export_from_gmsh_mesh( ...
%       "path/to/mesh.msh", "path/to/tissue_listing.txt", ...
%       "outputFolder", "path/to/out", "subjectName", "Sub01");
%
% See also: run, meshLoadGmsh4, export_segmentation_meshes
%

    arguments
        meshFile (1,1) string { mustBeFile }
        tissueListingFile (1,1) string { mustBeFile }
        kwargs.outputFolder (1,1) string = ""
        kwargs.dateTimeFormat (1,1) string = "yyyy-MM-dd-HH-mm-ss-SSS"
        kwargs.labelNameStr (1,1) string = "Label_Name:"
        kwargs.labelStr (1,1) string = "#No."
        kwargs.stlOutputFormat (1,1) string { mustBeMember(kwargs.stlOutputFormat, ["text", "binary"]) } = "binary"
        kwargs.subjectName (1,1) string = ""
    end

    dateTime    = datetime("now", Format = kwargs.dateTimeFormat);
    dateTimeStr = string(dateTime);

    % Load mesh (Gmsh 2.x/4.x binary or ASCII)
    meshStruct = utilities.sn2zef.meshLoadGmsh4(meshFile);

    % Load tissue table; header row often starts with #
    tissueTable = readtable(tissueListingFile, CommentStyle = '#', WhiteSpace = " \t");
    tissueFileLines = readlines(tissueListingFile);
    headerRowStr = "";
    for ii = 1 : numel(tissueFileLines)
        if startsWith(tissueFileLines(ii), "#")
            headerRowStr = tissueFileLines(ii);
            break;
        end
    end

    headerRowStrings = split(headerRowStr);
    % Handle column name with space (e.g. "Label Name:" vs "Label_Name:")
    if numel(headerRowStrings) > size(tissueTable, 2) && headerRowStrings(2) ~= kwargs.labelNameStr
        headerRowStrings(2) = strjoin([headerRowStrings(2), headerRowStrings(3)], "_");
        headerRowStrings(3 : 6) = headerRowStrings(4 : end);
        headerRowStrings(end) = [];
    end
    if numel(headerRowStrings) == size(tissueTable, 2)
        tissueTable.Properties.VariableNames = headerRowStrings;
    end
    if ismember(kwargs.labelNameStr, tissueTable.Properties.VariableNames)
        tissueTable = convertvars(tissueTable, kwargs.labelNameStr, "string");
    end

    if strlength(strtrim(kwargs.outputFolder)) == 0
        return;
    end

    writeToFiles = true;
    if ~isfolder(kwargs.outputFolder)
        warning("sn2zef:NoOutputFolder", "Output folder does not exist: ""%s"". Skipping file export.", kwargs.outputFolder);
        writeToFiles = false;
    end

    tissueLabels   = tissueTable.(kwargs.labelStr);
    tissueNames    = tissueTable.(kwargs.labelNameStr);
    meshNodes      = meshStruct.nodes;
    meshTriangles  = meshStruct.triangles;
    meshTetra      = meshStruct.tetrahedra;
    meshTriLabels  = meshStruct.triangle_regions;
    meshTetraLabels = meshStruct.tetrahedron_regions;

    subjectName = "";
    if strlength(strtrim(kwargs.subjectName)) > 0
        subjectName = kwargs.subjectName + ".";
    end

    outputPathWithDateTime = fullfile(kwargs.outputFolder, "mesh_export." + subjectName + dateTimeStr);
    if writeToFiles
        [status, message, messageID] = mkdir(outputPathWithDateTime);
        if status ~= 1
            warning("sn2zef:MkdirFailed", "Could not create folder ""%s"": %s (%s). Skipping file export.", outputPathWithDateTime, message, messageID);
            writeToFiles = false;
        end
    end

    if ~writeToFiles
        return;
    end

    % Per-compartment STLs (SimNIBS: triangle region = tissue label + 1000)
    for ii = 1 : numel(tissueLabels)
        triangleLabel = tissueLabels(ii) + 1000;
        name = tissueNames(ii);
        if ismissing(name) || strlength(strtrim(name)) == 0
            name = "Label_" + tissueLabels(ii);
        end
        nameChar = char(name);
        safeName = strrep(strrep(strrep(nameChar, ' ', '_'), '\', '_'), '/', '_');
        stlBaseName = string(safeName) + ".triangles.stl";

        triangleMask = (meshTriLabels == triangleLabel);
        if ~any(triangleMask)
            warning("sn2zef:NoTriangles", "Compartment ""%s"" has no triangles. Skipping STL.", nameChar);
            continue;
        end

        trianglePath = fullfile(outputPathWithDateTime, stlBaseName);
        disp("Writing triangles of " + name + " to " + trianglePath);
        relTris = meshTriangles(triangleMask, :);
        tri = triangulation(double(relTris), meshNodes);
        stlwrite(tri, trianglePath, kwargs.stlOutputFormat);
    end

    % Full mesh MAT
    wholeMeshMatPath = fullfile(outputPathWithDateTime, "wholemesh.mat");
    disp("Writing whole mesh to MAT file (" + wholeMeshMatPath + ")");
    mf = matfile(wholeMeshMatPath, Writable = true);
    mf.nodes = meshNodes;
    mf.triangles = meshTriangles;
    mf.triangleLabels = meshTriLabels;
    mf.tetra = meshTetra;
    mf.tetraLabels = meshTetraLabels;

    % Full mesh HDF5
    wholeMeshHDF5Path = fullfile(outputPathWithDateTime, "wholemesh.hdf5");
    disp("Writing whole mesh to HDF5 file (" + wholeMeshHDF5Path + ")");
    h5create(wholeMeshHDF5Path, '/mesh/nodes', size(meshNodes));
    h5create(wholeMeshHDF5Path, '/mesh/triangles', size(meshTriangles));
    h5create(wholeMeshHDF5Path, '/mesh/triangleLabels', size(meshTriLabels));
    h5create(wholeMeshHDF5Path, '/mesh/tetra', size(meshTetra));
    h5create(wholeMeshHDF5Path, '/mesh/tetraLabels', size(meshTetraLabels));
    h5write(wholeMeshHDF5Path, '/mesh/nodes', meshNodes);
    h5write(wholeMeshHDF5Path, '/mesh/triangles', meshTriangles);
    h5write(wholeMeshHDF5Path, '/mesh/triangleLabels', meshTriLabels);
    h5write(wholeMeshHDF5Path, '/mesh/tetra', meshTetra);
    h5write(wholeMeshHDF5Path, '/mesh/tetraLabels', meshTetraLabels);

end
