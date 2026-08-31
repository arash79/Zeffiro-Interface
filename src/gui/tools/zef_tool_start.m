function [zef] = zef_tool_start(zef,tool_script,relative_size,scale_positions)
%ZEF_TOOL_START  Lazy-launch a tool figure; skip a second copy by ZefTool tag.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. If findall(groot,'ZefTool',tool_script) hits, raise those
%   figures via zef_window_manager. Else evalc(['zef =' tool_script '(zef)']),
%   tag new ZEFFIRO Interface* figures, and append new numeric fields to
%   zef.zeffiro_variable_data (reloaded from the project MAT on later
%   opens). Sets zef_closereq and zef_set_size_change_function.
%
%   zef = zef_tool_start(zef, tool_script, relative_size, scale_positions)
%
%   See also zef_parcellation_tool, zef_window_manager.
if nargin < 3
    relative_size = 1/3;
end

if isempty(relative_size)
    relative_size = 1/3;
end

if nargin < 4
    scale_positions = 1;
end

h_tool = findall(groot,'ZefTool',tool_script);
screen_size_aux = get(0,'screensize');

if not(isempty(h_tool))
    if zef.use_display
        for i = 1 : length(h_tool)
            zef_window_manager('raise', h_tool(i));
        end
    end

else

    visible_val = get(0,'DefaultFigureVisible');
    set(0,'DefaultFigureVisible','off');
    h_groot = groot;
    h_groot_children_1 = findall(groot,'-regexp','Name','ZEFFIRO Interface*');
    J = [];
    if and(not(isempty(zef.zeffiro_variable_data)), not(isempty(zef.project_matfile)))
        I = find(ismember(zef.zeffiro_variable_data(:,1),tool_script));
        time_val = now;
        for i = 1 : length(I)
            try
                aux_var = load(zef.project_matfile,zef.zeffiro_variable_data{I(i),2});
                zef.(zef.zeffiro_variable_data{I(i),2}) = aux_var.(zef.zeffiro_variable_data{I(i),2});
                zef.zeffiro_variable_data{I(i),3} = time_val;
            catch
                J(end+1) = I(i);
            end
        end
    end
    if not(isempty(J))
        I = [1 : size(zef.zeffiro_variable_data,1)]';
        I = setdiff(I,J);
        zef.zeffiro_variable_data = zef.zeffiro_variable_data(I,:);
    end
    variable_list_1 = fieldnames(zef);

    evalc(['zef =' tool_script '(zef);']);

    variable_list_2 = fieldnames(zef);
    h_groot_children_2 = findall(groot,'-regexp','Name','ZEFFIRO Interface*');
    h_groot_children = setdiff(h_groot_children_2,h_groot_children_1);
    set(h_groot_children,'Visible',zef.use_display);
    variable_list = setdiff(variable_list_2,variable_list_1);
    I = [];
    for i = 1 : length(variable_list)
        if or(not(any(ishandle(zef.(variable_list{i})))),isnumeric(zef.(variable_list{i})))
            I(end+1) = i;
        end
    end
    variable_list = variable_list(I);
    time_val = now;
    variable_cell = [repmat({tool_script},length(variable_list),1) variable_list repmat({time_val},length(variable_list),1) repmat({time_val},length(variable_list),1) repmat({0},length(variable_list),1)];
    if not(isempty(zef.zeffiro_variable_data))
        variable_data_ind = [];
        for j = 1 : size(variable_cell,1)
            K = find(ismember(zef.zeffiro_variable_data(:,2),variable_cell(j,2)));
            if not(isempty(K))
                zef.zeffiro_variable_data(K,2:3) = variable_cell(j,2:3);
                variable_data_ind(end+1) = j;
            end
        end
        I = [1:size(variable_cell,1)]';
        variable_data_ind = variable_data_ind(:);
        variable_data_ind = setdiff(I,variable_data_ind);
        variable_cell = variable_cell(variable_data_ind,:);
    end
    zef.zeffiro_variable_data = [zef.zeffiro_variable_data; variable_cell];
    set(0,'DefaultFigureVisible',visible_val);

    h_anchor = zef_ui_anchor(zef);
    if isempty(h_anchor) || ~isvalid(h_anchor)
        h_anchor = zef.h_zeffiro_menu;
    end

    for i = 1 : length(h_groot_children)

        set(h_groot_children(i),'DeleteFcn',['zef_closereq(''' tool_script ''');'])

        h_groot_children(i).Units = h_anchor.Units;
        position_aux = h_groot_children(i).Position;
        width_aux = position_aux(3);
        height_aux = position_aux(4);
        scr = screen_size_aux;
        try
            if isappdata(h_groot_children(i), 'ZefMinSize')
                mins = getappdata(h_groot_children(i), 'ZefMinSize');
                width_aux = max(width_aux, mins(1));
                height_aux = max(height_aux, mins(2));
            end
        catch
        end
        if width_aux < 280
            width_aux = 420;
        end
        if height_aux < 160
            height_aux = 280;
        end
        width_aux = min(width_aux, min(0.99 * scr(3), scr(3) - 8));
        height_aux = min(height_aux, min(0.99 * scr(4), scr(4) - 8));
        try
            au = h_anchor.Units;
            h_anchor.Units = 'pixels';
            ap = double(h_anchor.Position);
            h_anchor.Units = au;
        catch
            ap = [80 80 800 600];
        end
        tool_pos = zef_ui_clamp_position( ...
            zef_ui_center_position([0 0 width_aux height_aux], ap), ...
            zef_ui_screen_workarea(ap));

        if not(isempty(findobj(h_groot_children(i),'-property','Resize')))
        h_groot_children(i).Resize = 'on';
        end

        try
            h_groot_children(i).AutoResizeChildren = 'off';
        catch
        end

        if not(ismember('ZefTool',properties(h_groot_children(i))))
            addprop(h_groot_children(i),'ZefTool');
        end
        h_groot_children(i).ZefTool = tool_script;
     
        zef_window_manager('standalone', h_groot_children(i), tool_pos);
        zef_ui_ready(h_groot_children(i));
        try
            has_grid = ~isempty(findall(h_groot_children(i), 'Tag', 'zef_ui_root'));
            has_form = isappdata(h_groot_children(i), 'ZefGuideForm');
            scf = [];
            try
                scf = h_groot_children(i).SizeChangedFcn;
            catch
            end
            if ~has_grid && ~has_form && ~isa(scf, 'function_handle')
                if isempty(findall(h_groot_children(i),'Type','uitable','-or','Type','uipanel'))
                    zef_set_size_change_function(h_groot_children(i),1,scale_positions);
                else
                    zef_set_size_change_function(h_groot_children(i),2,scale_positions);
                end
            end
        catch
        end
        try
            vis = 'off';
            if isprop(h_groot_children(i), 'Visible')
                vis = char(h_groot_children(i).Visible);
            end
            if strcmpi(vis, 'on')
                zef_window_manager('raise', h_groot_children(i));
            end
        catch
        end

    end

end

end
