function zef = zef_update_fss_ROI(zef)
%ZEF_UPDATE_FSS_ROI  Copy ROI-tool widgets onto zef.synth_source_ROI.
%
%   zef = zef_update_fss_ROI(zef)
%
%   The number of x-coordinate entries sets how many ROIs are packed
%   (size_1). Scalar widgets (style, noise, color, length, …) are
%   repeated. Vector widgets (radius, centres, orientations, amplitude)
%   must match size_1, or a single value is repeated. Extra values are
%   truncated with a warning; a short vector errors.
%
%   synth_source_ROI columns follow the widget order in this file (style,
%   radius, width, curvature, ori settings/xyz, centre xyz, dipole ori
%   style/xyz, amplitude, noise, plot style, color, length).
%
%   See also zef_find_source_ROI, zef_disable_box_ROIsource.

size_1 = size(str2num(get(zef.h_synth_source_ROI_x,'string')), 2);

% Define all fields and whether they should be repeated (true) or reshaped (false)
fields = {
    'h_synth_source_ROI_style',        'value',   true
    'h_synth_source_ROI_radius',       'string',  false
    'h_synth_source_ROI_width',        'string',  false
    'h_synth_source_ROI_curvature',    'string',  false
    'h_synth_source_ROI_ori_settings', 'value',   true
    'h_synth_source_ROI_ori_x',        'string',  false
    'h_synth_source_ROI_ori_y',        'string',  false
    'h_synth_source_ROI_ori_z',        'string',  false
    'h_synth_source_ROI_x',            'string',  false
    'h_synth_source_ROI_y',            'string',  false
    'h_synth_source_ROI_z',            'string',  false
    'h_synth_source_ROI_dipOri_style', 'value',   true
    'h_synth_source_ROI_dipOri_x',     'string',  false
    'h_synth_source_ROI_dipOri_y',     'string',  false
    'h_synth_source_ROI_dipOri_z',     'string',  false
    'h_synth_source_ROI_amp',          'string',  false
    'h_synth_source_ROI_noise',        'string',  true
    'h_synth_source_ROI_plot_style',   'value',   true
    'h_synth_source_ROI_color',        'value',   true
    'h_synth_source_ROI_length',       'string',  true
};

values = [];

for k = 1:size(fields,1)
    handleName = fields{k,1};
    prop       = fields{k,2};
    toRepeat   = fields{k,3};

    valRaw = get(zef.(handleName), prop);


    % Convert strings to numeric if needed
    if strcmp(prop, 'string')
        val = str2num(valRaw);
    else
        val = valRaw;
    end

    % repeat or reshape, if reshaping not possible then try to repeat 
    if toRepeat
        valVec = repmat(val, size_1, 1);
    else
        if numel(val) == size_1  
            valVec = reshape(val, size_1, 1);
        elseif numel(val) == 1
            valVec = repmat(val, size_1, 1);
        elseif numel(val) == 0 %eg if input is not a number
            error('Field %s is empty or invalid.', handleName)
        else
            warning('Number of entries in field %s do not match field %s', handleName,fields{9,1})
            if numel(val)>size_1 %just cut off the amount of values needed
                valVec = val(1:size_1);
            else 
                error('Can not resolve mismatch.')
            end
        end
    end

    values = [values valVec];
end

zef.synth_source_ROI = values;

end



