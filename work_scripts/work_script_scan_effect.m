lens1 = Lens(2, -3);
lens2 = Lens(0.4, 0);
beam = Beam(515e-9, 377.038e-6 * 2, -5, 1.15);
% beam = Beam(343e-9, 294.787e-6 * 2, -4.7, 2.7);
table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);
table.add_lens(lens2);

z = linspace(-0.3, 0.3, 600)';
waist_pos = zeros(1, 600)';
waist = zeros(1, 600)';
size_at_specimen = zeros(1, 600)';
size_at_final_mirror = zeros(1, 600)';

for i = 1 : 600
    lens2.move_to(z(i));
    waist_pos(i) = beam.beam_segments(3, 2);
    waist(i) = beam.beam_segments(3, 1);
    size_at_specimen(i) = beam.size(z(i) + 0.4);
    size_at_final_mirror(i) = beam.size(z(i) + 0.3853);
end

waist_pos = waist_pos .* 100;
waist = waist .* 1e6;
size_at_specimen = size_at_specimen .* 1e6;
size_at_final_mirror = size_at_final_mirror .* 1e6;


figure

yyaxis left
plot(z, waist_pos, 'LineWidth', 1.5)
xlabel('Light path change (m)')
ylabel('Waist position (cm)')
title(['beam during a scan: ', num2str(lens1.f), 'm lens @ ', num2str(lens1.pos), 'm, ', num2str(beam.lambda*1e9), 'nm, waist pos ', num2str(beam.beam_segments(1, 2)), 'm'])

yyaxis right 
plot(z, waist, 'LineWidth', 1.5)
hold on
plot(z, size_at_specimen, 'LineWidth', 1.5)
plot(z, size_at_final_mirror, 'LineWidth', 1.5)
ylabel('Beam size (um)')
legend('waist position', 'at waist', 'at specimen', 'at final mirror')

path = 'C:\Users\Jialiang Chen\!School\PhD\Research\Data Processing\Laser\20201029';
saveas(gcf, fullfile(path, [num2str(beam.lambda*1e9), '_beam_change_lens_pos_', num2str(lens1.pos), 'm']), 'png')

