classdef ZefSourceModel
% ZefSourceModel — Enumeration of source and interpolation models for Zeffiro.
%
% This class defines the finite-element source and interpolation models used
% in the Zeffiro Interface forward and inverse solvers. Each variant
% corresponds to a specific mathematical formulation (e.g. Whitney, H(div),
% St. Venant) in either standard or continuous form.
%
% Enumeration members:
%   Hdiv               — H(div)-conforming (Raviart–Thomas) source model.
%   Whitney            — Whitney (edge) element source model.
%   StVenant           — St. Venant source model.
%   ContinuousHdiv     — Continuous H(div) variant.
%   ContinuousWhitney  — Continuous Whitney variant.
%   ContinuousStVenant — Continuous St. Venant variant.
%   Error              — Sentinel value indicating an invalid or unknown model.
%
% See also: core.ZefSourceModel.from, core.ZefSourceModel.variants,
%           core.ZefSourceModel.to_string.

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

        function self = loadobj ( obj_or_struct )
        % loadobj — Restore ZefSourceModel from saved .mat or struct.
        %
        % Converts a struct or a ZefSourceModel instance loaded from a .mat
        % file into a valid in-memory ZefSourceModel. Used by MATLAB's load()
        % when the saved object's class definition has changed or was stored
        % as a struct.
        %
        % Input:
        %   obj_or_struct (1,1) — Saved value: ZefSourceModel enum or struct
        %       with field ValueNames (e.g. from older save format).
        %
        % Output:
        %   self (1,1) core.ZefSourceModel — Restored enumeration member.
        %       Defaults to Hdiv if the input cannot be interpreted.

            arguments
                obj_or_struct (1,1)
            end

            classname = string ( class ( obj_or_struct ) ) ;

            % Default used when input is not a valid ZefSourceModel or struct.
            self = core.ZefSourceModel.Hdiv ;

            if endsWith ( classname, "ZefSourceModel" )

                self = obj_or_struct ;

            elseif classname == "struct"

                if isfield ( obj_or_struct, "ValueNames" )

                    self = core.ZefSourceModel.from ( obj_or_struct.ValueNames ) ;

                end

            end % if

        end % function

    end % methods

    methods (Static)

        function source_model = from(p_input)
        % from — Create ZefSourceModel from string, numeric, or enum input.
        %
        % Maps legacy numeric codes (1–6), string equivalents ("1"–"6"), or
        % an existing ZefSourceModel enum to the corresponding enumeration
        % member. Returns Error for invalid or unrecognized input.
        %
        % Input:
        %   p_input — Scalar: double (1–6), char/string ("1"–"6"), or
        %       core.ZefSourceModel. Idempotent when given an enum.
        %
        % Output:
        %   source_model (1,1) core.ZefSourceModel — Matched variant or Error.
        %
        % Numeric mapping: 1=Whitney, 2=Hdiv, 3=StVenant, 4=ContinuousWhitney,
        %                 5=ContinuousHdiv, 6=ContinuousStVenant.

            source_model = core.ZefSourceModel.Error;

            if nargin ~= 1
                warning ( 'ZefSourceModel.from: Exactly one input is required. Returning Error.' );
                return
            end

            % Idempotent: passing an existing enum returns it unchanged.
            if isenum(p_input)

                switch p_input
                    case core.ZefSourceModel.Error
                        source_model = p_input;
                    case core.ZefSourceModel.Whitney
                        source_model = p_input;
                    case core.ZefSourceModel.Hdiv
                        source_model = p_input;
                    case core.ZefSourceModel.StVenant
                        source_model = p_input;
                    case core.ZefSourceModel.ContinuousWhitney
                        source_model = p_input;
                    case core.ZefSourceModel.ContinuousHdiv
                        source_model = p_input;
                    case core.ZefSourceModel.ContinuousStVenant
                        source_model = p_input;
                    otherwise
                        warning ( "ZefSourceModel.from: Input enum is not a ZefSourceModel. Returning Error." );
                        source_model = core.ZefSourceModel.Error;
                end

                return

            end

            % Map legacy numeric codes (1–6) to enumeration members.
            KNOWN_INTEGERS = [1, 2, 3, 4, 5, 6];

            if isreal(p_input)

                if p_input == 1
                    source_model = core.ZefSourceModel.Whitney;
                elseif p_input == 2
                    source_model = core.ZefSourceModel.Hdiv;
                elseif p_input == 3
                    source_model = core.ZefSourceModel.StVenant;
                elseif p_input == 4
                    source_model = core.ZefSourceModel.ContinuousWhitney;
                elseif p_input == 5
                    source_model = core.ZefSourceModel.ContinuousHdiv;
                elseif p_input == 6
                    source_model = core.ZefSourceModel.ContinuousStVenant;
                else
                    source_model = core.ZefSourceModel.Error;
                end

            end

            % Map string codes "1"–"6" to enumeration members.
            if ischar(p_input) || isstring(p_input)

                if strcmp(p_input, '1')
                    source_model = core.ZefSourceModel.Whitney;
                elseif strcmp(p_input, '2')
                    source_model = core.ZefSourceModel.Hdiv;
                elseif strcmp(p_input, '3')
                    source_model = core.ZefSourceModel.StVenant;
                elseif strcmp(p_input, '4')
                    source_model = core.ZefSourceModel.ContinuousWhitney;
                elseif strcmp(p_input, '5')
                    source_model = core.ZefSourceModel.ContinuousHdiv;
                elseif strcmp(p_input, '6')
                    source_model = core.ZefSourceModel.ContinuousStVenant;
                else
                    source_model = core.ZefSourceModel.Error;
                end

            end

            if source_model == core.ZefSourceModel.Error
                warning ( "ZefSourceModel.from: Invalid input. Use one of %s.", mat2str(KNOWN_INTEGERS) );
            end

        end % from

        function vars = variants()
        % variants — Return all ZefSourceModel enumeration members.
        %
        % Output:
        %   vars — Column vector of core.ZefSourceModel members. Includes the
        %       Error sentinel; filter it out if only valid source models are
        %       needed. Obtained via enumeration() without constructing instances.

            source_model = core.ZefSourceModel.Hdiv;
            vars = enumeration ( source_model );

        end

    end % methods (Static)

    methods

        function str = to_string(variant)
        % to_string — Human-readable string for a ZefSourceModel variant.
        %
        % Input:
        %   variant (1,1) core.ZefSourceModel — Enumeration member.
        %
        % Output:
        %   str (1,1) string — Display name (e.g. "Whitney", "H(div)").
        %       Returns "None" for unrecognized values.

            switch variant

                case core.ZefSourceModel.Whitney

                    str = "Whitney";

                case core.ZefSourceModel.Hdiv

                    str = "H(div)";

                case core.ZefSourceModel.StVenant

                    str = "St. Venant";

                case core.ZefSourceModel.ContinuousWhitney

                    str = "Continuous Whitney";

                case core.ZefSourceModel.ContinuousHdiv

                    str = "Continuous H(div)";

                case core.ZefSourceModel.ContinuousStVenant

                    str = "Continuous St. Venant";

                case core.ZefSourceModel.Error

                    str = "Error";

                otherwise

                    str = "None";

            end % switch

        end % function

    end % methods

end % classdef
