function zef_PlotSourceButton_Callback(~, ~)
%ZEF_PLOTSOURCEBUTTON_CALLBACK  Stem-plot the selected tree node's source on h_axes1.
%
%   Figure-tool overlay: reads zef.h_source_tree.SourceTree and zef.h_axes1
%   from the base workspace, then zef_plot_selected_source_to_axes_stem
%   with DeletePrevious and StoreHandleToZef. Errors if those handles are
%   missing (tool not open / Figure tool closed).
%
%   See also zef_plot_selected_source_to_axes_stem, zef_plot_outPub.

try
   treeObj = evalin('base','zef.h_source_tree.SourceTree');
catch
    error('PlotSourceButton: treeObj not found in base workspace.');
end

try
    h_axes = evalin('base','zef.h_axes1');
catch
    error('PlotSourceButton: zef.h_axes1 not found in base workspace.');
end

% -------------------------------------------------
% Call stem plotting routine
% -------------------------------------------------
zef_plot_selected_source_to_axes_stem(treeObj, h_axes, ...
    'DeletePrevious', true, ...
    'StoreHandleToZef', true, ...
    'Tag', 'additional: selected tree source');

end

