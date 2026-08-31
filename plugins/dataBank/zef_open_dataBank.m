function zef = zef_open_dataBank(zef)
%ZEF_OPEN_DATABANK  Build the Data Bank window and wire buttons.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add snapshots Entrytype from live zef; Load copies a node back.
%   Combine: [zef.L, zef.measurements] = zef_dataBank_combineLeadFields(...).
%
%   zef = zef_open_dataBank(zef)
%

zef.dataBank.app=zef_dataBank_app;

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
zef.dataBank.app.exportMenu.MenuSelectedFcn="disp('sorry, this is not implemented,yet')";
zef.dataBank.app.modifyMenu.MenuSelectedFcn=strcat('zef.dataBank.selectMultiple=true;', 'zef_dataBank_getHashForMenu;', ...
    'zef.dataBank.workingHashes=zef_dataBank_hashToWorkingSpace(zef.dataBank.hash, zef.dataBank.workingHashes);', ...
    '[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_WorkingSpaceInfo(zef.dataBank.tree, zef.dataBank.workingHashes);');
zef.dataBank.app.changeNameMenu.MenuSelectedFcn='zef_dataBank_startNameChange;';
zef.dataBank.app.showinformationMenu.MenuSelectedFcn='zef_dataBank_getHashForMenu; disp(zef.dataBank.tree.(zef.dataBank.hash)); disp(zef.dataBank.tree.(zef.dataBank.hash).data);';

zef.dataBank.app.showworkingHashes.ButtonPushedFcn = '[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_WorkingSpaceInfo(zef.dataBank.tree, zef.dataBank.workingHashes);';
zef.dataBank.app.loadMenuData.MenuSelectedFcn='zef.dataBank.loadParents=false; zef_dataBank_getHashForMenu;zef_dataBank_setData;';
zef.dataBank.app.loadwithparentsMenuData.MenuSelectedFcn='zef.dataBank.loadParents=true; zef_dataBank_getHashForMenu;zef_dataBank_setData;';
zef.dataBank.app.showinformationMenuData.MenuSelectedFcn='zef_dataBank_getHashForTableMenu; disp(zef.dataBank.tree.(zef.dataBank.hash{1})); disp(zef.dataBank.tree.(zef.dataBank.hash{1}).data);';
zef.dataBank.app.deleteMenuData.MenuSelectedFcn=strcat('zef.dataBank.selectMultiple=false;', 'zef_dataBank_getHashForTableMenu;', ...
    'zef.dataBank.tree=zef_dataBank_delete(zef.dataBank.tree, zef.dataBank.hash, zef.dataBank.save2disk);','  zef_dataBank_refreshTree;', ...
    'zef.dataBank.selectMultiple=false;', ...
    '[zef.dataBank.app.DataTable.Data, zef.dataBank.app.DataTable.ColumnName, zef.dataBank.DataTableHashList]=zef_databank_showAll(zef.dataBank.tree, zef.dataBank.app.Entrytype.Value);');

zef.dataBank.app.modifyMenuData.MenuSelectedFcn=strcat('zef.dataBank.selectMultiple=true;', 'zef_dataBank_getHashForTableMenu;', ...
    'zef.dataBank.workingHashes=zef_dataBank_hashToWorkingSpace(zef.dataBank.hash, zef.dataBank.workingHashes);', ...
    '[zef.dataBank.app.currentTable.Data, zef.dataBank.app.currentTable.ColumnName]=zef_dataBank_WorkingSpaceInfo(zef.dataBank.tree, zef.dataBank.workingHashes);');

set(zef.dataBank.app.DataBank,'AutoResizeChildren','off');
zef_set_size_change_function(zef.dataBank.app.DataBank,2);
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

try
    btns = [zef.dataBank.app.addButton, zef.dataBank.app.showButton, ...
        zef.dataBank.app.showcurrentButton, zef.dataBank.app.showworkingHashes];
    for zef_i = 1:numel(btns)
        p = btns(zef_i).Position;
        p(1) = 8;
        p(3) = 150;
        btns(zef_i).Position = p;
    end
    zef.dataBank.app.showworkingHashes.Tooltip = 'Show working hashes';
    cb = zef.dataBank.app.combineButton;
    lab = strtrim(char(string(cb.Text)));
    need = max(150, 8 * numel(lab) + 20);
    p = cb.Position;
    p(3) = max(p(3), need);
    cb.Position = p;
    cb.Tooltip = lab;
catch
end
try
    zef_ui_apply_size(zef.dataBank.app.DataBank, 1280, 640, 960, 500);
    zef_ui_fit_dropdowns(zef.dataBank.app.DataBank);
    try
        fig = zef.dataBank.app.DataBank;
        fig.Units = 'pixels';
        fw = fig.Position(3);
        dd = zef.dataBank.app.FunctionsDropDown;
        p = dd.Position;
        dd.Position = [p(1) p(2) max(p(3), 220) p(4)];
        cm = zef.dataBank.app.combineMenu;
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
        extra = need - p(3);
        if extra > 0
            room = max(0, fw - 16 - (p(1) + p(3)));
            grow = min(extra, room);
            if grow > 0
                cm.Position = [p(1) p(2) p(3) + grow p(4)];
            end
        end
        try
            pan = zef.dataBank.app.combinePanel;
            pan.Units = 'pixels';
            pp = pan.Position;
            remain = max(160, fw - pp(1) - 12);
            pan.Position(3) = min(max(pp(3), 280), remain);
        catch
        end
        try
            zef.dataBank.app.combineMenu.Tooltip = strjoin(string(zef.dataBank.app.combineMenu.Items), newline);
        catch
        end
        cb = zef.dataBank.app.combineButton;
        p = cb.Position;
        lab = strtrim(char(string(cb.Text)));
        need = max(p(3), min(220, 8 * numel(lab) + 24));
        cb.Position = [p(1) p(2) need p(4)];
        cb.Tooltip = lab;
    catch
    end
    zef_set_size_change_function(zef.dataBank.app.DataBank, 2);
    zef_ui_bind_min_size(zef.dataBank.app.DataBank, 960, 500);
    try
        gs = findall(zef.dataBank.app.DataBank, 'Type', 'uigridlayout');
        for zef_i = 1:numel(gs)
            cw = gs(zef_i).ColumnWidth;
            if iscell(cw) && numel(cw) >= 3
                cw{end} = '1x';
                gs(zef_i).ColumnWidth = cw;
            end
        end
    catch
    end
catch
end

end
