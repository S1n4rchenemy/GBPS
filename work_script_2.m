lens1 = Lens(2, -2);
lens2 = Lens(0.4, 0);
beam = Beam(343e-9, 114.143e-6 * 2, -5, 1.15);
table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);
table.add_lens(lens2);

z = linspace(-4, -1, 3000)';
waist_pos = zeros(1, 3000)';
waist = zeros(1, 3000)';
size_at_specimen = zeros(1, 3000)';
size_at_final_mirror = zeros(1, 3000)';

for i = 1 : 3000
    lens1.move_to(z(i));
    waist_pos(i) = beam.beam_segments(3, 2);
    waist(i) = beam.beam_segments(3, 1);
    size_at_specimen(i) = beam.size(0.4);
    size_at_final_mirror(i) = beam.size(0.3853);
end

waist_pos = waist_pos .* 100;
waist = waist .* 1e6;
size_at_specimen = size_at_specimen .* 1e6;
size_at_final_mirror = size_at_final_mirror .* 1e6;


figure

yyaxis left
plot(z, waist_pos, 'LineWidth', 1.5)
xlabel('Lens position (m)')
ylabel('Waist position (cm)')
title('UV pump with 2-m lens at various positions')

yyaxis right 
plot(z, waist, 'LineWidth', 1.5)
hold on
plot(z, size_at_specimen, 'LineWidth', 1.5)
plot(z, size_at_final_mirror, 'LineWidth', 1.5)
ylabel('Beam size (um)')
legend('waist position', 'at waist', 'at specimen', 'at final mirror')



    