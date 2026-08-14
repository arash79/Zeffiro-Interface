classdef ZefSourceModel
%ZEFSOURCEMODEL  Enumeration of FEM source discretizations used in lead-field assembly.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Members: Whitney, Hdiv, StVenant, ContinuousWhitney, ContinuousHdiv,
%   ContinuousStVenant, and Error (sentinel). Legacy numeric codes 1–6
%   (and the strings "1"–"6") are mapped by from(). to_string() returns
%   display names such as "H(div)". variants() lists all members including
%   Error. loadobj maps a saved value through from(); if that yields
%   Error it becomes Hdiv so a corrupt .mat still loads a valid model.
%
%   Used by src/forward/lead_field when assembling zef.L, and by the
%   Forward & inverse options GUI dropdown.
%
%   See also core.ZefSourceModel, zef_lead_field_matrix.

    enumeration
        Hdiv
        Whitney
        StVenant
        ContinuousHdiv
        ContinuousWhitney
        ContinuousStVenant
        Error
    end

    methods

        function self = loadobj(obj_or_struct)
        % loadobj — Restore ZefSourceModel from saved .mat or struct.

            self = core.types.ZefSourceModel.from(obj_or_struct);
            if self == core.types.ZefSourceModel.Error
                self = core.types.ZefSourceModel.Hdiv;
            end
        end

    end % methods

    methods (Static)

        function source_model = from(p_input)
        % from — Create ZefSourceModel from string, numeric, or enum input.
        %
        % Maps legacy numeric codes (1–6), member names ("Hdiv"), display
        % names ("H(div)"), structs with ValueNames, core.ZefSourceModel,
        % or an existing core.types.ZefSourceModel. Returns Error for
        % unrecognized input.
        %
        % Input:
        %   p_input — Scalar: double (1–6), char/string ("1"–"6"), or
        %       core.types.ZefSourceModel. Idempotent when given an enum.
        %
        % Output:
        %   source_model (1,1) core.types.ZefSourceModel — Matched variant or Error.
        %
        % Numeric mapping: 1=Whitney, 2=Hdiv, 3=StVenant, 4=ContinuousWhitney,
        %                 5=ContinuousHdiv, 6=ContinuousStVenant.

            source_model = core.types.ZefSourceModel.Error;

            if nargin ~= 1
                warning('ZefSourceModel.from: Exactly one input is required. Returning Error.');
                return
            end

            if iscell(p_input)
                if isempty(p_input)
                    return
                end
                source_model = core.types.ZefSourceModel.from(p_input{1});
                return
            end

            if isstruct(p_input)
                if isfield(p_input, 'ValueNames')
                    source_model = core.types.ZefSourceModel.from(p_input.ValueNames);
                end
                return
            end

            if isenum(p_input)
                if isa(p_input, 'core.types.ZefSourceModel')
                    source_model = p_input;
                    return
                end
                source_model = core.types.ZefSourceModel.from(string(p_input));
                return
            end

            if isnumeric(p_input) && isscalar(p_input) && isreal(p_input)
                if p_input == 1
                    source_model = core.types.ZefSourceModel.Whitney;
                elseif p_input == 2
                    source_model = core.types.ZefSourceModel.Hdiv;
                elseif p_input == 3
                    source_model = core.types.ZefSourceModel.StVenant;
                elseif p_input == 4
                    source_model = core.types.ZefSourceModel.ContinuousWhitney;
                elseif p_input == 5
                    source_model = core.types.ZefSourceModel.ContinuousHdiv;
                elseif p_input == 6
                    source_model = core.types.ZefSourceModel.ContinuousStVenant;
                end
                if source_model == core.types.ZefSourceModel.Error
                    warning('ZefSourceModel.from: Invalid input. Use one of %s.', mat2str(1:6));
                end
                return
            end

            if ischar(p_input) || isstring(p_input)
                txt = string(p_input);
                key = lower(strtrim(char(txt(1))));
                key = strrep(strrep(strrep(key, ' ', ''), '.', ''), '_', '');
                switch key
                    case {'1', 'whitney'}
                        source_model = core.types.ZefSourceModel.Whitney;
                    case {'2', 'hdiv', 'h(div)'}
                        source_model = core.types.ZefSourceModel.Hdiv;
                    case {'3', 'stvenant'}
                        source_model = core.types.ZefSourceModel.StVenant;
                    case {'4', 'continuouswhitney'}
                        source_model = core.types.ZefSourceModel.ContinuousWhitney;
                    case {'5', 'continuoushdiv', 'continuoush(div)'}
                        source_model = core.types.ZefSourceModel.ContinuousHdiv;
                    case {'6', 'continuousstvenant'}
                        source_model = core.types.ZefSourceModel.ContinuousStVenant;
                    case {'error'}
                        source_model = core.types.ZefSourceModel.Error;
                    otherwise
                        warning('ZefSourceModel.from: Invalid input. Use one of %s.', mat2str(1:6));
                end
            end

        end % from

        function vars = variants()
        % variants — Return all ZefSourceModel enumeration members.
        %
        % Output:
        %   vars — Column vector of core.types.ZefSourceModel members. Includes the
        %       Error sentinel; filter it out if only valid source models are
        %       needed. Obtained via enumeration() without constructing instances.

            source_model = core.types.ZefSourceModel.Hdiv;
            vars = enumeration ( source_model );

        end

    end % methods (Static)

    methods

        function str = to_string(variant)
        % to_string — Human-readable string for a ZefSourceModel variant.
        %
        % Input:
        %   variant (1,1) core.types.ZefSourceModel — Enumeration member.
        %
        % Output:
        %   str (1,1) string — Display name (e.g. "Whitney", "H(div)").
        %       Returns "None" for unrecognized values.

            switch variant

                case core.types.ZefSourceModel.Whitney

                    str = "Whitney";

                case core.types.ZefSourceModel.Hdiv

                    str = "H(div)";

                case core.types.ZefSourceModel.StVenant

                    str = "St. Venant";

                case core.types.ZefSourceModel.ContinuousWhitney

                    str = "Continuous Whitney";

                case core.types.ZefSourceModel.ContinuousHdiv

                    str = "Continuous H(div)";

                case core.types.ZefSourceModel.ContinuousStVenant

                    str = "Continuous St. Venant";

                case core.types.ZefSourceModel.Error

                    str = "Error";

                otherwise

                    str = "None";

            end % switch

        end % function

    end % methods

end % classdef
