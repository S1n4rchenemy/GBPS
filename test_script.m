% test the initializations of beam, lens, and optic table
beam = Beam(515e-9, 2e-3, 0, 1.1);
lens = Lens(0.1, 0.1);
lens2 = Lens(0.1, 50e-3);
table = OpticTable;

% test the addition of beam and lenses to the optic table
table.add_beam(beam);
table.add_lens(lens);
table.add_lens(lens2);

% test moving the lens
lens.move_to(0.2);

% test changing the focal length of a lens
lens.change_to(0.2);

% test the plot generation funciton of OpticTable
table.plot_gen([-0.1 0.5])

