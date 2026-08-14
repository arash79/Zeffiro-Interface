function [meshStruct, tissueTable] = export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)
%EXPORT_FROM_GMSH_MESH  Legacy Gmsh .msh surface export (open sheets).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [meshStruct, tissueTable] = export_from_gmsh_mesh(meshFile, ...
%       tissueListingFile, kwargs)
%
%   Loads via vendor meshLoadGmsh4. Optional kwargs.outputFolder writes STLs.
%   Surfaces are single-sided tissue interfaces, not watertight shells.
%   Prefer export_segmentation_meshes / run for Zeffiro import.
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