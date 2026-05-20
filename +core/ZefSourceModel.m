classdef ZefSourceModel
% --- Zeffiro documentation header ---
% core.ZefSourceModel — Zef Source Model.
%
% Purpose:
%   Zef Source Model.
%   Folder: Refactored MATLAB package at the project root: typed source models (`core.types.ZefSourceModel`), electrode I/O (`core.io.electrodes`), one menu callback for electrode import, and optional preconditioner builders (`core.linalg.preconditioners`). Loaded when the project root is on the path.
%
% Inputs:
%   obj_or_struct
%
% Calls (project):
%   core.types.ZefSourceModel.from
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `core.ZefSourceModel(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header

    methods (Static)

        function self = loadobj(obj_or_struct)
        % loadobj — Map legacy saved values to core.types.ZefSourceModel.
        %
        % Input:
        %   obj_or_struct — Struct from MATLAB when the original enum class
        %       is missing (typically has field ValueNames), or any saved value.
        %
        % Output:
        %   self (1,1) core.types.ZefSourceModel — Restored enumeration member.

            arguments
                obj_or_struct (1,1)
            end

            self = core.types.ZefSourceModel.Hdiv;

            if isstruct(obj_or_struct) && isfield(obj_or_struct, "ValueNames")
                self = core.types.ZefSourceModel.from(obj_or_struct.ValueNames);
            elseif isenum(obj_or_struct)
                self = core.types.ZefSourceModel.from(obj_or_struct);
            end

        end

    end

end
