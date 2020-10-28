lens1 = Lens(2, -2);
beam = Beam(515e-9, 377.038e-6 * 2, -5, 1.15);
table = OpticTable;

table.add_beam(beam);
table.add_lens(lens1);

z = linspace(-4.5, -1.5, 3000)';
divg = zeros(3000, 1);

for i = 1 : 3000
    lens1.move_to(z(i))
    divg(i) = beam.beam_segments(2, 3);
end

figure
plot(z, divg)