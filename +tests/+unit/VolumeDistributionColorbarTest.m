classdef VolumeDistributionColorbarTest < matlab.unittest.TestCase
%VOLUMEDISTRIBUTIONCOLORBARTEST  Volume distribution must not paint the colormap over the mesh.
%
%   zef_plot_volume visualization_type 2 calls zef_figure_place_colorbar.
%   colorbar() followed by Location 'manual' freezes Position at the
%   default normalized [0 0 1 1]. That rectangle is the whole figure view,
%   so the axes colormap (Monterosso by default) covers the head.

    properties
        Figures = gobjects(0)
    end

    methods (TestMethodTeardown)
        function cleanupFigures(testCase)
            for i = 1:numel(testCase.Figures)
                if isgraphics(testCase.Figures(i)) && isvalid(testCase.Figures(i))
                    delete(testCase.Figures(i));
                end
            end
            testCase.Figures = gobjects(0);
        end
    end

    methods (Test)
        function placeColorbarDoesNotCoverTheAxes(testCase)
            [fig, ax] = local_figure_view(testCase);
            surf(ax, peaks(12));
            view(ax, 0, 0);
            h = zef_figure_place_colorbar(ax);
            testCase.assertNotEmpty(h);
            testCase.assertTrue(isvalid(h));
            % Same follow-up as zef_plot_volume: axis image, then the
            % figure-view slot restore in zef_figure_sync_plot.
            axis(ax, 'image');
            view(ax, 0, 0);
            ax.Units = 'pixels';
            ax.InnerPosition = [1 1 518 333];
            local_assert_strip(testCase, h, ax);
        end

        function volumeDistributionKeepsMeshVisible(testCase)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(root);
            zef = zeffiro_interface('start_mode', 'nodisplay', ...
                'use_gpu', false, 'exit_zeffiro', false);
            testCase.Figures(end + 1) = zef.h_zeffiro; %#ok<AGROW>
            [nodes, tetra, labels] = local_box_and_brain();
            zef.nodes = nodes;
            zef.tetra = tetra;
            zef.domain_labels = labels;
            zef.compartment_tags = {'box', 'brain'};
            zef.box_on = 1;
            zef.box_sigma = 0.3;
            zef.box_priority = 1;
            zef.box_visible = 1;
            zef.box_color = [0.2 0.7 0.3];
            zef.box_sources = 0;
            zef.box_name = 'Box';
            zef.brain_on = 1;
            zef.brain_sigma = 0.33;
            zef.brain_priority = 2;
            zef.brain_visible = 1;
            zef.brain_color = [0.8 0.2 0.2];
            zef.brain_sources = 1;
            zef.brain_name = 'Brain';
            zef.name_tags = {'Box', 'Brain'};
            active = find(labels == 2);
            zef.active_compartment_ind = active;
            zef.brain_ind = active;
            cents = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) + ...
                nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;
            v = cents(active, 1);
            M = repmat((v(:)' / sqrt(3)), 3, 1);
            zef.reconstruction = M(:);
            zef.source_interpolation_ind = {repmat((1:numel(v))', 1, 4), [], []};
            zef.visualization_type = 2;
            zef.volumetric_distribution_mode = 1;
            zef.reconstruction_type = 1;
            zef.cp_on = 0;
            zef.cp2_on = 0;
            zef.cp3_on = 0;
            zef.use_parcellation = 0;
            zef.inv_scale = 2;
            zef.inv_colormap = 1;
            zef.smooth_field_steps = 0;
            zef.sensors = [0 0 0];
            zef.current_sensors = 'eeg';
            zef.eeg_visible = 0;
            zef.attach_electrodes = 0;
            zef.imaging_method = 1;
            zef.layer_transparency = 1;
            zef.brain_transparency = 1;
            zef.axes_visible = 0;
            zef.azimuth = 0;
            zef.elevation = 0;
            assignin('base', 'zef', zef);
            zef_plot_volume();
            zef = evalin('base', 'zef');
            ax = zef.h_axes1;
            h = findall(ancestor(ax, 'figure'), 'Tag', 'rightColorbar');
            testCase.assertNotEmpty(h);
            local_assert_strip(testCase, h(1), ax);
            recon = findall(ax, 'Type', 'patch', 'Tag', 'reconstruction');
            testCase.verifyNotEmpty(recon);
            testCase.verifyEqual(char(string(recon(1).FaceColor)), 'flat');
            testCase.verifyEqual(size(recon(1).Faces, 1), size(recon(1).FaceVertexCData, 1));
        end
    end
end

function [fig, ax] = local_figure_view(testCase)

fig = figure('Visible', 'off', 'Position', [40 40 900 640]);
testCase.Figures(end + 1) = fig; %#ok<AGROW>
panel = uipanel('Parent', fig, 'Units', 'pixels', ...
    'Position', [12 12 520 335], 'Tag', 'figure_view', ...
    'BorderType', 'none');
ax = axes('Parent', panel, 'Units', 'pixels', ...
    'Position', [1 1 518 333], 'Tag', 'axes1');
try
    ax.PositionConstraint = 'innerposition';
catch
end

end

function local_assert_strip(testCase, h, ax)

h.Units = 'pixels';
ax.Units = 'pixels';
pos = h.Position;
ap = ax.InnerPosition;
testCase.verifyLessThan(pos(3), 40, ...
    'Colorbar width covers the volume axes.');
testCase.verifyGreaterThan(pos(4), 40, ...
    'Colorbar is not a vertical scale.');
cx = ap(1) + ap(3) / 2;
cy = ap(2) + ap(4) / 2;
covers = cx >= pos(1) && cx <= pos(1) + pos(3) && ...
    cy >= pos(2) && cy <= pos(2) + pos(4);
testCase.verifyFalse(covers, ...
    'Colorbar rectangle contains the axes center.');

end

function [nodes, tetra, labels] = local_box_and_brain()

n = 4;
[x, y, z] = ndgrid(0:n, 0:n, 0:n);
nodes = [x(:), y(:), z(:)];
idx = @(i, j, k) i + j * (n + 1) + k * (n + 1) ^ 2 + 1;
tetra = zeros(0, 4);
labels = zeros(0, 1);
for ix = 0:n - 1
    for iy = 0:n - 1
        for iz = 0:n - 1
            a = idx(ix, iy, iz);
            b = idx(ix + 1, iy, iz);
            c = idx(ix, iy + 1, iz);
            d = idx(ix + 1, iy + 1, iz);
            e = idx(ix, iy, iz + 1);
            f = idx(ix + 1, iy, iz + 1);
            g = idx(ix, iy + 1, iz + 1);
            h = idx(ix + 1, iy + 1, iz + 1);
            if mod(ix + iy + iz, 2) == 0
                tloc = [a b d e; b d f e; d g e f; a d c e; d g h f];
            else
                tloc = [a b c f; a c e f; c d h f; c g e f; c e g h];
            end
            tetra = [tetra; tloc]; %#ok<AGROW>
            cents = (nodes(tloc(:, 1), :) + nodes(tloc(:, 2), :) + ...
                nodes(tloc(:, 3), :) + nodes(tloc(:, 4), :)) / 4;
            inner = all(cents > 1 & cents < 3, 2);
            labels = [labels; 1 + inner]; %#ok<AGROW>
        end
    end
end

end
