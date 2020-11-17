clear

lens1 = Lens(1, 0);

% beam = Beam(515e-9, 377.038e-6 * 2, 0, 1.29);
% beam.set_divergence(1.67e-3);

% beam = Beam(343e-9, 294.787e-6 * 2, 0, 3.7);
% beam.set_divergence(2e-3)

beam = Beam(1030e-9, 377.038e-6 * 2, 0, 1.15);
beam.set_divergence(3.1e-3)

table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);

frac = 0.5;
start = (1 - frac) * lens1.f;
final = (1 + frac) * lens1.f;

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
    lens1.move_to(z(i))
    divg(i) = beam.beam_segments(2, 3);
    zR(i) = beam.beam_segments(2, 4);
    size1(i) = beam.size(place1);
    size2(i) = beam.size(place2);
    size3(i) = beam.size(place3);
end

divg = divg .* 1000;
zR = zR .* 1000;
size1 = size1 .* 1000;
size2 = size2 .* 1000;
size3 = size3 .* 1000;

figure
yyaxis left
% plot(z, divg, z, divg_UV, 'LineWidth', 1.5)
plot(z, divg, 'LineWidth', 1.5)
xlabel('Relative Lens Position (m)')
ylabel('Divergence (mrad)')
title(['\Theta & z_R vs. Lens Position: ', num2str(lens1.f), 'm lens, ', num2str(beam.lambda*1e9), 'nm beam'])
grid on

yyaxis right
plot(z, zR, '--', 'LineWidth', 1.5)
ylabel('Rayleigh Length (mm)')
legend('Divergence', 'Rayleigh Length')
axis tight

path = 'C:\Users\Jialiang Chen\!School\PhD\Research\Data Processing\Laser\20201104\IR_lens_design';
% saveas(gcf, fullfile(path, [num2str(beam.lambda*1e9),'_','divg_zR_lens_pos_', num2str(lens1.f*1000), 'mm_lens']), 'png')

figure
plot(z, size1, z, size2, z, size3, 'LineWidth', 1.5)
xlabel('Second Lens Relative Position (m)')
ylabel('Beam Diameter (mm)')
title(['\Theta & z_R vs. Lens Position: ', num2str(lens1.f), 'm lens, ', num2str(beam.lambda*1e9), 'nm beam'])
legend(['@ ', num2str(place1), 'm'], ['@ ', num2str(place2), 'm'], ['@ ', num2str(place3), 'm'])
grid on
axis tight