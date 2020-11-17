clear

lens1 = Lens(-0.05, 0.6);
lens2 = Lens(0.15, 0.3);

% beam = Beam(515e-9, 377.038e-6 * 2, 0, 1.29);
% beam.set_divergence(1.67e-3);

beam = Beam(343e-9, 294.787e-6 * 2, 0, 3.7);
beam.set_divergence(2e-3)

table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);
table.add_lens(lens2);

base_dist = lens2.f + lens1.f;
frac = 0.5;
start = lens1.pos + (1 - frac) * base_dist;
final = lens1.pos + (1 + frac) * base_dist;

place1 = 1.2;
place2 = 2;
place3 = 3;

sampling = 1000;    % set sampling numbers
z = linspace(start, final, sampling)';
divg = zeros(sampling, 1);
zR = zeros(sampling, 1);
size1 = zeros(sampling, 1);
size2 = zeros(sampling, 1);
size3 = zeros(sampling, 1);

for i = 1 : sampling
    lens2.move_to(z(i))
    divg(i) = beam.beam_segments(3, 3);
    zR(i) = beam.beam_segments(3, 4);
    size1(i) = beam.size(place1);
    size2(i) = beam.size(place2);
    size3(i) = beam.size(place3);
end

z_plot = z - lens1.pos;
divg = divg .* 1000;
zR = zR .* 1000;
size1 = size1 .* 1000;
size2 = size2 .* 1000;
size3 = size3 .* 1000;

figure
yyaxis left
% plot(z, divg, z, divg_UV, 'LineWidth', 1.5)
plot(z_plot, divg, 'LineWidth', 1.5)
xlabel('Second Lens Relative Position (m)')
ylabel('Divergence (mrad)')
title(['Telescope: ', num2str(beam.lambda*1e9), 'nm beam, ', num2str(lens1.f), 'm & ', num2str(lens2.f), 'm lenses'])
grid on

yyaxis right
plot(z_plot, zR, '--', 'LineWidth', 1.5)
ylabel('Rayleigh Length (mm)')
legend('Divergence', 'Rayleigh Length')
text(0.1, 0.88, ['First lens at ', num2str(lens1.pos), ' m'], 'Units', 'normalized')
axis tight

path = 'C:\Users\Jialiang Chen\!School\PhD\Research\Data Processing\Laser\20201104\UV_lens_design\galilean_telescope';
% saveas(gcf, fullfile(path, [num2str(beam.lambda*1e9),'_GT_', num2str(lens1.f*1000), ...
%     'mm_', num2str(lens2.f*1000), 'mm_lenses_at_', num2str(lens1.pos*100), 'cm']), 'png')

figure
plot(z_plot, size1, z_plot, size2, z_plot, size3, 'LineWidth', 1.5)
xlabel('Second Lens Relative Position (m)')
ylabel('Beam Diameter (mm)')
title(['Telescope: ', num2str(beam.lambda*1e9), 'nm beam, ', num2str(lens1.f), 'm & ', num2str(lens2.f), 'm lenses'])
legend(['@ ', num2str(place1), 'm'], ['@ ', num2str(place2), 'm'], ['@ ', num2str(place3), 'm'])
grid on
axis tight
