
datasheet_path = 'C:\Users\Jialiang Chen\!School\PhD\Research\Data Processing\Laser\20201104\';
datasheet_filename = 'IR_with_150mm_lens.xlsx';

% Uncomment the line below to enable GUI file selection
%[datasheet_filename, datasheet_path] = uigetfile('*.*', 'Select the datasheet file');

opts = detectImportOptions([datasheet_path, datasheet_filename]);
opts.Sheet = 2;         % index of the sheet to be imported
datasheet = readtable([datasheet_path, datasheet_filename], opts);

lambda = 1030e-3;        % beam wavelength in [um] 

d_fac = 1;     % the scaling factor for d_sigma
pos_fac = 1000;     % default value is 1000 since the unit of pos is [mm], while the unit of d_sigma is [um]

pos_index = 2;        % column 1 in the datasheet is the default column of the distance
d_sigma_index = 7;       % column 7 in the datasheet is the default column of the d4sigmax
pos = datasheet.(pos_index);
d_sigma = datasheet.(d_sigma_index) ./ d_fac;

[fitresult, gof, h] = createFit(pos, d_sigma);

divergence = sqrt(fitresult.c) * d_fac;     % divergence in unit [mrad]
waist_pos = -fitresult.b / 2 / fitresult.c;     % waist position in uint [mm]
d_waist = 1 / 2/ sqrt(fitresult.c) * sqrt(fitresult.a * fitresult.c * 4 - fitresult.b^2) * d_fac;       % waist diameter in unit [um]
rayleigh_length = d_waist / divergence;     % rayleigh length in unit [mm]
M_sq = d_waist * divergence/ 1000 / 4 * (pi / lambda);

results_str = {['waist diameter = ', num2str(d_waist), 'um'], ...
                ['waist position = ', num2str(waist_pos), ' mm'], ...
                ['divergence = ', num2str(divergence), ' mrad'], ...
                ['Rayleigh length = ', num2str(rayleigh_length), ' mm'], ...
                ['M square = ', num2str(M_sq)]};
text(0.02, 0.88, results_str, 'Units', 'normalized')
title([datasheet_filename(1:end-5), ': Dx'], 'Interpreter', 'none')

% comment the line below to disable auto saving
% saveas(gcf, fullfile(datasheet_path(1:end-1), 'UV_150mm_Dx'), 'png')