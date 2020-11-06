clear

lens1 = Lens(-0.05, 0.2);
lens2 = Lens(0.1, 0.3);

% beam = Beam(515e-9, 377.038e-6 * 2, 0, 1.29);
% beam.set_divergence(1.67e-3);

beam = Beam(343e-9, 294.787e-6 * 2, 0, 3.7);
beam.set_divergence(2e-3)

table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);
table.add_lens(lens2);

base_dist = lens2.f + lens1.f;
frac = 0.1;
start = lens1.pos + (1 - frac) * base_dist;
final = lens1.pos + (1 + frac) * base_dist;

sampling = 1000;    % set sampling numbers
z = linspace(start, final, sampling)';
divg = zeros(sampling, 1);
zR = zeros(sampling, 1);

for i = 1 : sampling
    lens2.move_to(z(i))
    divg(i) = beam.beam_segments(3, 3);
    zR(i) = beam.beam_segments(3, 4);
end

divg = divg .* 1000;
zR = zR .* 1000;
figure
yyaxis left
% plot(z, divg, z, divg_UV, 'LineWidth', 1.5)
plot(z, divg, 'LineWidth', 1.5)
xlabel('Convex Lens Position (m)')
ylabel('Divergence (mrad)')
title(['Galilean Telescope: ', num2str(beam.lambda*1e9), 'nm beam, ', num2str(lens1.f), 'm & ', num2str(lens2.f), 'm lenses'])
grid on

yyaxis right
plot(z, zR, '--', 'LineWidth', 1.5)
ylabel('Rayleigh Length (mm)')
legend('Divergence', 'Rayleigh Length')
text(0.1, 0.88, ['Concave lens at ', num2str(lens1.pos), ' m'], 'Units', 'normalized')
axis tight

path = 'C:\Users\Jialiang Chen\!School\PhD\Research\Data Processing\Laser\20201104\UV_lens_design\galilean_telescope';
% saveas(gcf, fullfile(path, [num2str(beam.lambda*1e9),'_GT_', num2str(lens1.f*1000), ...
%     'mm_', num2str(lens2.f*1000), 'mm_lenses_at_', num2str(lens1.pos*100), 'cm']), 'png')