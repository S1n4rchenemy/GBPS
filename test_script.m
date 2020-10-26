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

% test the Beam.size method
beam_size_test = beam.size(0.1)

% test the Beam.change_to method
% ===================================================================
beam.change_to(1030e-9);
table.plot_gen([-0.1 0.5])

beam.change_to(515e-9, 1);
beam.change_to(515e-9, 1.1, 0.6);
beam.change_to(515e-9, 1.1, 0, 4e-3);
% ===================================================================

% uncomment the below block to test the Lens.remvoe method
% ===================================================================
% lens.remove();
% check_removed_from_table_lens_list = ~ismember(lens, table.lenses)
% check_lens_has_no_table = isempty(lens.table)
% table.plot_gen([-0.1 0.5])
% ===================================================================

% uncomment the below block to test the Beam.remove method
% ===================================================================
% beam.remove();
% beam_segments_after_removed = beam.beam_segments
% check_beam_has_no_table = isempty(beam.table)
% table.plot_gen()
% ===================================================================

% uncomment the below block to test the OpticTable.remove_part method
% ===================================================================
table.remove_part(lens)
check_removed_from_table_lens_list = ~ismember(lens, table.lenses)
check_lens_has_no_table = isempty(lens.table)
table.plot_gen([-0.1 0.5])

table.remove_part(lens2)
check_removed_from_table_lens_list = ~ismember(lens, table.lenses)
check_lens_has_no_table = isempty(lens.table)
table.plot_gen()

table.remove_part(beam)
beam_segments_after_removed = beam.beam_segments
check_beam_has_no_table = isempty(beam.table)
table.plot_gen()
% ===================================================================

