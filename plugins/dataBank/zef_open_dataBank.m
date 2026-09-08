function zef = zef_open_dataBank(zef)
%ZEF_OPEN_DATABANK  Build the Data Bank window and wire buttons.
%
%   Zeffiro Interface.
%   Copyright 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add snapshots Entrytype from live zef; Load copies a node back.
%   Combine: [zef.L, zef.measurements] = zef_dataBank_combineLeadFields(...).
%
%   zef = zef_open_dataBank(zef)
%

zef.dataBank.app=zef_dataBank_app;

try
    setappdata(zef.dataBank.app.DataBank, 'ZefDataBankApp', zef.dataBank.app);
catch
end

zef = zef_dataBank_init(zef);

%intitial values

if ~isfield(zef.dataBank, 'folder')
    zef.dataBank.save2disk='Off';
else
    if ~isfield(zef.dataBank, 'save2disk')
        zef.dataBank.save2disk='Off';
    end
    zef.dataBank.app.DataFolder.Text=zef.dataBank.folder;
    zef.dataBank.app.savetodiskSwitch.Enable=true;
    zef.dataBank.app.savetodiskSwitch.Value=zef.dataBank.save2disk;
end

zef.dataBank.app.Tree.SelectionChangedFcn = 'zef_dataBank_getHashForMenu;';
zef.dataBank.app.addButton.ButtonPushedFcn='zef_dataBank_addButtonPress;';
zef.dataBank.app.combineButton.ButtonPushedFcn='[zef.L, zef.measurements] = zef_dataBank_combineLeadFields(zef.dataBank.tree, zef.dataBank.workingHashes,zef.dataBank.app.combineMenu.Value,zef.dataBank.var_starttime,zef.dataBank.var_endtime,zef.dataBank.var_sampling_frequency);';
zef.dataBank.app.StarttimeSpinner.ValueChangedFcn = 'zef_dataBank_update;';
zef.dataBank.app.EndtimeSpinner.ValueChangedFcn = 'zef_dataBank_update;';
zef.dataBank.app.SfreqSpinner.ValueChangedFcn = 'zef_dataBank_update;';
zef.dataBank.app.WorkingdataClear.MenuSelectedFcn = ' zef.dataBank.app.currentTable.Data = cell(0);zef.dataBank.workingHashes=cell(0);';
zef.dataBank.types={'data', 'noisedata', 'leadfield', 'reconstruction', 'gmm', 'custom', 'import'}; %%%% edit for new datatype!
zef.dataBank.app.Entrytype.Items=zef.dataBank.types;
zef.dataBank.app.Entrytype.ValueChangedFcn = '[zef.dataBank.app.DataTable.Data, zef.dataBank.app.DataTable.ColumnName, zef.dataBank.DataTableHashList]=zef_databank_showAll(zef.dataBank.tree, zef.dataBank.app.Entrytype.Value);';

zef.dataBank.app.showButton.ButtonPushedFcn='[zef.dataBank.app.DataTable.Data, zef.dataBank.app.DataTable.ColumnName, zef.dataBank.DataTableHashList]=zef_databank_showAll(zef.dataBank.tree, zef.dataBank.app.Entrytype.Value);';
zef.dataBank.app.showcurrentButton.ButtonPushedFcn='[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_showCurrent(zef, zef.dataBank.app.Entrytype.Value);';
zef.dataBank.app.RefreshButton.ButtonPushedFcn='zef_dataBank_refreshTree;';

zef.dataBank.app.selectfolderButton.ButtonPushedFcn='zef_dataBank_saveFolderButtonPush;';

zef.dataBank.app.savetodiskSwitch.ValueChangedFcn='zef_dataBank_saveTreeNodeSwitchChange;';

zef.dataBank.app.FunctionsDropDown.ValueChangedFcn='zef_dataBank_FunctionsDropDown;';

%set functions for the import panel

zef.dataBank.app.importButton.ButtonPushedFcn='zef_dataBank_importNodeButtonPress;';
zef.dataBank.app.exportButton.ButtonPushedFcn='zef_dataBank_exportButtonPress;';

zef.dataBank.app.loadMenu.MenuSelectedFcn='zef.dataBank.loadParents=false; zef_dataBank_getHashForMenu;zef_dataBank_setData;';
zef.dataBank.app.loadwithparentsMenu.MenuSelectedFcn='zef.dataBank.loadParents=true; zef_dataBank_getHashForMenu;zef_dataBank_setData;';
zef.dataBank.app.deleteMenu.MenuSelectedFcn='zef.dataBank.selectMultiple=false; zef_dataBank_getHashForMenu; zef.dataBank.tree=zef_dataBank_delete(zef.dataBank.tree, zef.dataBank.hash,zef.dataBank.save2disk); zef_dataBank_refreshTree,   zef.dataBank.selectMultiple=false;';
zef.dataBank.app.exportMenu.MenuSelectedFcn = ...
    "disp('Tree-menu export is not implemented. Use the Export button to save a node or the whole tree.')";
zef.dataBank.app.modifyMenu.MenuSelectedFcn=strcat('zef.dataBank.selectMultiple=true;', 'zef_dataBank_getHashForMenu;', ...
    'zef.dataBank.workingHashes=zef_dataBank_hashToWorkingSpace(zef.dataBank.hash, zef.dataBank.workingHashes);', ...
    '[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_WorkingSpaceInfo(zef.dataBank.tree, zef.dataBank.workingHashes);');
zef.dataBank.app.changeNameMenu.MenuSelectedFcn='zef_dataBank_startNameChange;';
zef.dataBank.app.showinformationMenu.MenuSelectedFcn='zef_dataBank_getHashForMenu; disp(zef.dataBank.tree.(zef.dataBank.hash)); disp(zef.dataBank.tree.(zef.dataBank.hash).data);';

zef.dataBank.app.showworkingHashes.ButtonPushedFcn = '[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_WorkingSpaceInfo(zef.dataBank.tree, zef.dataBank.workingHashes);';
zef.dataBank.app.loadMenuData.MenuSelectedFcn='zef.dataBank.loadParents=false; zef_dataBank_getHashForMenu;zef_dataBank_setData;';
zef.dataBank.app.loadwithparentsMenuData.MenuSelectedFcn='zef.dataBank.loadParents=true; zef_dataBank_getHashForMenu;zef_dataBank_setData;';
zef.dataBank.app.showinformationMenuData.MenuSelectedFcn='zef_dataBank_getHashForMenu; zef_dataBank_getHashForTableMenu; disp(zef.dataBank.tree.(zef.dataBank.hash{1})); disp(zef.dataBank.tree.(zef.dataBank.hash{1}).data);';
zef.dataBank.app.deleteMenuData.MenuSelectedFcn=strcat('zef.dataBank.selectMultiple=false;', 'zef_dataBank_getHashForTableMenu;', ...
    'zef.dataBank.tree=zef_dataBank_delete(zef.dataBank.tree, zef.dataBank.hash, zef.dataBank.save2disk);','  zef_dataBank_refreshTree;', ...
    'zef.dataBank.selectMultiple=false;', ...
    '[zef.dataBank.app.DataTable.Data, zef.dataBank.app.DataTable.ColumnName, zef.dataBank.DataTableHashList]=zef_databank_showAll(zef.dataBank.tree, zef.dataBank.app.Entrytype.Value);');

zef.dataBank.app.modifyMenuData.MenuSelectedFcn=strcat('zef.dataBank.selectMultiple=true;', 'zef_dataBank_getHashForTableMenu;', ...
    'zef.dataBank.workingHashes=zef_dataBank_hashToWorkingSpace(zef.dataBank.hash, zef.dataBank.workingHashes);', ...
    '[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_WorkingSpaceInfo(zef.dataBank.tree, zef.dataBank.workingHashes);');

set(zef.dataBank.app.DataBank,'AutoResizeChildren','off');
try
    panels = findall(zef.dataBank.app.DataBank, 'Type', 'uipanel');
    for zef_i = 1:numel(panels)
        panels(zef_i).AutoResizeChildren = 'off';
    end
catch
end
% load all data and stuff

if ~isfield(zef.dataBank, 'tree')
    zef.dataBank.tree=struct;
else
    zef =  zef_dataBank_hash2tree(zef);
end

zef.dataBank.loadParents=false;
zef.dataBank.selectMultiple=false;

[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_showCurrent(zef, zef.dataBank.app.Entrytype.Value);
[zef.dataBank.app.DataTable.Data, zef.dataBank.app.DataTable.ColumnName, zef.dataBank.DataTableHashList]=zef_databank_showAll(zef.dataBank.tree, zef.dataBank.app.Entrytype.Value);

% Hide off-screen legacy panels until the layout pass places them.
try
    zef.dataBank.app.importPanel.Visible = 'off';
    zef.dataBank.app.mag2gragPanel.Visible = 'off';
    zef.dataBank.app.showworkingHashes.Tooltip = 'Show working hashes';
    zef.dataBank.app.combineButton.Tooltip = strtrim(char(string( ...
        zef.dataBank.app.combineButton.Text)));
catch
end

try
    app = zef.dataBank.app;
    zef_ui_apply_size(app.DataBank, 980, 640, 840, 520);
    zef_ui_bind_min_size(app.DataBank, 840, 520);
    zef_layout_data_bank(app.DataBank);
catch
end

end

function local_databank_app_resize(~, ~, prev, app)
try
    if isa(prev, 'function_handle')
        prev(app.DataBank, []);
    elseif (ischar(prev) || isstring(prev)) && strlength(prev) > 0
        evalin('base', char(prev));
    end
catch
end
try
    local_databank_clamp_controls(app);
catch
end
try
    local_databank_fix_working_label(app);
catch
end
end

function local_databank_clamp_controls(app)
if nargin < 1 || (~isstruct(app) && ~isobject(app)) || ~isprop(app, 'DataBank')
    return
end
try
    fig = app.DataBank;
    fig.Units = 'pixels';
    fw = fig.Position(3);

    dd = app.FunctionsDropDown;
    p = dd.Position;
    dd.Position = [p(1) p(2) min(max(p(3), 220), max(80, fw - 16 - p(1))) p(4)];

    cm = app.combineMenu;
    p = cm.Position;
    longest = 0;
    try
        items = cm.Items;
        for zef_k = 1:numel(items)
            longest = max(longest, numel(char(string(items{zef_k}))));
        end
    catch
    end
    need = max(p(3), min(520, 36 + 7 * max(longest, 24)));
    try
        pan = app.combinePanel;
        pan.Units = 'pixels';
        pp = pan.Position;
        % Shrink the panel so it stays inside the figure.
        remain = max(160, fw - pp(1) - 12);
        pan.Position(3) = min(max(pp(3), 280), remain);
        % The dropdown is inside the panel; account for both the figure edge
        % and the panel's internal right edge.
        max_cm_w = max(80, fw - 16 - (pp(1) + p(1)));
        max_cm_w = min(max_cm_w, max(40, pp(3) - p(1) - 12));
        need = min(need, max_cm_w);
    catch
        need = min(need, max(80, fw - 16 - p(1)));
    end
    if need ~= p(3)
        cm.Position = [p(1) p(2) need p(4)];
    end
    try
        app.combineMenu.Tooltip = strjoin(string(app.combineMenu.Items), newline);
    catch
    end

    cb = app.combineButton;
    p = cb.Position;
    lab = strtrim(char(string(cb.Text)));
    need = max(p(3), min(220, 8 * numel(lab) + 24));
    room = max(80, fw - 12 - p(1));
    cb.Position = [p(1) p(2) min(need, room) p(4)];
    cb.Tooltip = lab;
catch
end

% Generic safety pass for any dropdown, button, spinner, or label that still
% extends past the right edge.
try
    fig = app.DataBank;
    fig.Units = 'pixels';
    fw = fig.Position(3);
    ctr = [findall(fig, 'Type', 'uidropdown'); findall(fig, 'Type', 'uibutton'); ...
        findall(fig, 'Type', 'uispinner'); findall(fig, 'Type', 'uilabel')];
    for zef_k = 1:numel(ctr)
        try
            if ~strcmpi(char(ctr(zef_k).Visible), 'on')
                continue
            end
            gp = getpixelposition(ctr(zef_k), true);
            if numel(gp) < 4
                continue
            end
            over = (gp(1) + gp(3)) - (fw - 8);
            if over > 0 && gp(3) > 40
                p = ctr(zef_k).Position;
                p(3) = max(40, p(3) - over);
                ctr(zef_k).Position = p;
            end
        catch
        end
    end
catch
end
end

function local_databank_fix_working_label(app)

if nargin < 1 || isempty(app)
    return
end
try
    lab = app.dataLabel;
    tbl = app.currentTable;
    tp = double(tbl.Position);
    lp = double(lab.Position);
    inner_h = inf;
    try
        pan = app.DataPanel;
        inner_h = double(pan.Position(4)) - 26;
    catch
    end
    top_need = max(lp(4), 22) + 4;
    if isfinite(inner_h) && (tp(2) + tp(4) + top_need) > inner_h && tp(2) > 8
        tbl.Position(4) = max(48, inner_h - top_need - tp(2));
        tp = double(tbl.Position);
    end
    lab.Position = [tp(1), tp(2) + tp(4) + 4, max(lp(3), 90), max(lp(4), 22)];
catch
end
try
    dd = app.FunctionsDropDown;
    fl = app.FunctionsLabel;
    dp = double(dd.Position);
    lp = double(fl.Position);
    fl.Position = [max(8, dp(1) - lp(3) - 8), dp(2), lp(3), lp(4)];
catch
end
try
    fig = app.DataBank;
    fig.Units = 'pixels';
    fw = double(fig.Position(3));
    ctr = [app.FunctionsDropDown; app.combineMenu; app.combineButton];
    for i = 1:numel(ctr)
        try
            gp = getpixelposition(ctr(i), true);
            over = (gp(1) + gp(3)) - (fw - 8);
            if over > 0
                ctr(i).Position(3) = max(40, ctr(i).Position(3) - over);
            end
        catch
        end
    end
catch
end
try
    if app.importPanel.Position(2) < 0
        app.importPanel.Visible = 'off';
    end
    if app.mag2gragPanel.Position(2) < 0
        app.mag2gragPanel.Visible = 'off';
    end
catch
end

end
