lens1 = Lens(2, 0);
beam = Beam(515e-9, 377.038e-6 * 2, 0, 1.15);
% beam = Beam(343e-9, 294.787e-6 * 2, 0.3, 2.7);
table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);

sampling = 3000;    % set sampling numbers
z = linspace(0.8, 3.8, sampling)';
divg = zeros(sampling, 1);
zR = zeros(sampling, 1);

for i = 1 : sampling
    lens1.move_to(z(i))
    divg(i) = beam.beam_segments(2, 3);
    zR(i) = beam.beam_segments(2, 4);
end

divg = divg .* 1000;
zR = zR .* 1000;
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

path = 'C:\Users\Jialiang Chen\!School\PhD\Research\Data Processing\Laser\20201029';
saveas(gcf, fullfile(path, ['divg_zR_lens_pos_', num2str(beam.lambda*1e9)]), 'png')

