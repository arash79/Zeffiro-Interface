function zef = zef_update_parcellation(zef)
%ZEF_UPDATE_PARCELLATION  Refresh Parcellation-tool widgets from zef (not widget→zef).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Pushes zef.parcellation_* onto h_parcellation_name,
%   tolerance, ROI name/center/radius/color, ROI list, time-series mode,
%   plot type, segment, and h_parcellation_list (HTML listbox before
%   R2025a, colored table after). List markers: green V = interpolated
%   (status 2), orange V = points but no interp (1), red X = not in
%   colortable map (0). **Activate** / **Active**
%   button color follows zef.use_parcellation. Import buttons turn red
%   when colortable/points are empty. nargout==0 → assignin base.
%
%   See also zef_init_parcellation, zef_plot_parcellation_time_series.
if nargin==0
    zef = evalin('base','zef');
end

set(zef.h_parcellation_name,'string',zef.parcellation_name);
set(zef.h_parcellation_tolerance,'string',num2str(zef.parcellation_tolerance));
zef_sel = zef.parcellation_roi_selected;
if isempty(zef_sel) || ~isscalar(zef_sel) || zef_sel < 1
    zef_sel = 1;
    zef.parcellation_roi_selected = 1;
end
n_roi = 0;
try
    n_roi = numel(zef.parcellation_roi_name);
catch
end
if n_roi < 1
    zef.parcellation_roi_name = {'ROI 1'};
    zef.parcellation_roi_center = [0 0 0];
    zef.parcellation_roi_radius = 0;
    zef.parcellation_roi_color = [0.2 0.5 0.6];
    n_roi = 1;
end
zef_sel = min(zef_sel, n_roi);
zef.parcellation_roi_selected = zef_sel;
zef.h_parcellation_roi_name.String = zef.parcellation_roi_name{zef_sel};
zef.h_parcellation_roi_center.String = num2str(zef.parcellation_roi_center(zef_sel,:));
zef.h_parcellation_roi_radius.String = num2str(zef.parcellation_roi_radius(zef_sel));
zef.h_parcellation_roi_color.String = num2str(zef.parcellation_roi_color(zef_sel,:));
zef.h_parcellation_roi_color.BackgroundColor = zef.parcellation_roi_color(zef_sel,:);
zef.h_parcellation_roi_list.Value = zef_sel;
zef.h_parcellation_roi_list.String = zef.parcellation_roi_name;
zef.h_parcellation_time_series_mode.Value = zef.parcellation_time_series_mode;

zef.parcellation_list = cell(0);
parcellation_colors = zeros(0, 3);
parcellation_markers = cell(0);
parcellation_marker_colors = zeros(0, 3);

zef_k = 0;
zef.parcellation_status = [];
zef.parcellation_colormap = [100 100 100]/255;
for zef_j = 1 : length(zef.parcellation_colortable)
    zef.parcellation_colormap = [zef.parcellation_colormap ; double(zef.parcellation_colortable{zef_j}{3}(:,1:3))/255];
    for zef_i = 1 : size(zef.parcellation_colortable{zef_j}{2},1)
        zef_k = zef_k + 1;
        label = [zef.parcellation_colortable{zef_j}{1}  ' ' num2str(zef_i,'%03d') ' '  ': ' zef.parcellation_colortable{zef_j}{2}{zef_i}];
        rgb = double(zef.parcellation_colortable{zef_j}{3}(zef_i,1:3));
        if max(rgb) > 1
            rgb = rgb / 255;
        end
        if not(isempty(find(ismember(zef.parcellation_colortable{zef_j}{4},zef.parcellation_colortable{zef_j}{3}(zef_i,5)))))
            if length(zef.parcellation_interp_ind) >= zef_k
                if not(isempty(zef.parcellation_interp_ind{zef_k}))
                    zef.parcellation_status(zef_k) = 2;
                else
                    zef.parcellation_status(zef_k) = 1;
                end
            else
                zef.parcellation_status(zef_k) = 1;
            end
        else
            zef.parcellation_status(zef_k) = 0;
        end
        zef.parcellation_list{zef_k} = label;
        parcellation_colors(zef_k, :) = rgb;
        if zef.parcellation_status(zef_k) == 0
            parcellation_markers{zef_k} = 'X';
            parcellation_marker_colors(zef_k, :) = [1 0 0];
        elseif zef.parcellation_status(zef_k) == 2
            parcellation_markers{zef_k} = 'V';
            parcellation_marker_colors(zef_k, :) = [0 0.6 0];
        else
            parcellation_markers{zef_k} = 'V';
            parcellation_marker_colors(zef_k, :) = [1 0.5 0];
        end
    end
end
if isempty(zef.parcellation_list)
    zef.parcellation_list = {};
end
if isfield(zef, 'h_parcellation_list') && isvalid(zef.h_parcellation_list)
    zef_colored_list('set', zef.h_parcellation_list, zef.parcellation_list, parcellation_colors, ...
        'Markers', parcellation_markers, 'MarkerColors', parcellation_marker_colors);
    if ~isempty(zef.parcellation_selected)
        zef_colored_list('value', zef.h_parcellation_list, zef.parcellation_selected);
    end
end
clear zef_i zef_j zef_k;

set(zef.h_use_parcellation,'value',zef.use_parcellation);
set(zef.h_parcellation_plot_type,'value',zef.parcellation_plot_type);
set(zef.h_parcellation_segment,'string',zef.parcellation_segment);

if zef.use_parcellation == 0
    set(zef.h_use_parcellation,'foregroundcolor',[0 0 0]);
    set(zef.h_use_parcellation,'string','Activate');
else
    set(zef.h_use_parcellation,'foregroundcolor',[1 0 0]);
    set(zef.h_use_parcellation,'string','Active');
end

zef.parcellation_colormap = 0.5*zef.parcellation_colormap;

if  isempty(eval('zef.parcellation_colortable'))
    set(zef.h_import_parcellation_colortable,'foregroundcolor',[1 0 0]);
else
    set(zef.h_import_parcellation_colortable,'foregroundcolor',[0 0 0]);
end

if  isempty(eval('zef.parcellation_points'))
    set(zef.h_zef_import_parcellation_points,'foregroundcolor',[1 0 0]);
else
    set(zef.h_zef_import_parcellation_points,'foregroundcolor',[0 0 0]);
end

if (isempty(zef.parcellation_selected) && not(isempty(zef.parcellation_list)))
    zef.parcellation_selected = 1:numel(zef.parcellation_list);
    if isfield(zef, 'h_parcellation_list') && isvalid(zef.h_parcellation_list)
        zef_colored_list('value', zef.h_parcellation_list, zef.parcellation_selected);
    end
end

if isfield(zef,'parcellation_status')

    if not(isempty(zef.parcellation_status))
        if ismember(1,zef.parcellation_status(zef.parcellation_selected))
            set(zef.h_parcellation_interpolation,'foregroundcolor',[1 0.5 0]);
        end
    end

end

if isfield(zef,'parcellation_list')
    zef = rmfield(zef,'parcellation_list');
end

if isfield(zef,'parcellation_status')
    zef = rmfield(zef,'parcellation_status');
end

if nargout == 0
    assignin('base','zef',zef);
end

end
