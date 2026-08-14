function [file, file_path, mesh_type] = zef_import_surface_mesh_type
%ZEF_IMPORT_SURFACE_MESH_TYPE  Dialog to pick surface mesh import type and file.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens a modal dialog to choose STL (full mesh), points DAT, or triangles
%   DAT, then uigetfile for the matching extension. Returns 0 for file and
%   path when the user cancels.
%
%   [file, file_path, mesh_type] = zef_import_surface_mesh_type()
%
%   Outputs
%     file      - selected file name, or 0 if cancelled.
%     file_path - folder of file, or 0 if cancelled.
%     mesh_type - popup index (1 STL, 2 points, 3 triangles), or -1
%                 before selection.
%
%   See also zef_get_mesh, zef_import_segmentation.

file = 0;
file_path = 0;
mesh_type = -1;

selection_cell = {'stl','points','triangles'};

d = dialog('Position',[300 300 350 150],'Name','Select One','Resize','on');
txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[72 90 210 40],...
    'String','Choose mesh item for importing.');

popup = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[80 55 200 25],...
    'String',{'Full mesh (STL)';'Points (DAT)';'Triangles (DAT)'});

select_button = uicontrol('Style', 'pushbutton', ...
    'Position', [80 30 100 25], 'String','OK', 'Callback',@selected_button);

cancel_button = uicontrol('Style', 'pushbutton', ...
    'Position', [180 30 100 25], 'String','Cancel', 'Callback','closereq;');

uiwait(d);

    function selected_button(popup,event)
        mesh_type = get(select_button,'Value');
        if ismember(mesh_type,[1])
            [file file_path] = uigetfile('*.stl');
        elseif ismember(mesh_type,[2 3])
            [file file_path] = uigetfile('*.dat');
        end
        close(d)
    end
end
