classdef Beam < handle
    properties
        lambda      % wavelength of the beam
        M2      % M_square factor
        beam_segments = double.empty(0, 6)      % an array storing the beam parameters of each beam segments separated by lenses
                                                % Example: beam_segments(i, :) = [beam waist diameter, waist position, divergence full angle, Rayleigh length, lens position, lens focal length]
        table = OpticTable.empty        % optic table where the beam is added
        profile = struct('z', [], 'radius', [])     % structure array storing the beam profile (i.e. beam waist radius evolution along the propagation direction z) 
        color = cell.empty(0, 2)        % color used to generate the beam profile plot
    end
    
    methods
        function self = Beam(lambda, waist, z0, M2)
            % constructor of a object of Beam class
            if nargin < 4
                self.M2 = 1;        % default M2 factor, 1 for ideal Gaussian beam
            else
                self.M2 = M2;
            end
            
            self.lambda = lambda;
            init_divg = 4 * self.M2 * self.lambda / pi / waist;
            init_zR = waist / init_divg;
            self.beam_segments(1, :) = [waist, z0, init_divg, init_zR, 0, 0];
            
            % determine the beam profile color based on its wavelength
            if lambda > 620e-9
                self.color = {'#F44336', [244/255 67/255 54/255]};
            elseif lambda > 590e-9
                self.color = {'#FB8C00', [251/255 140/255 0]};
            elseif lambda > 570e-9
                self.color = {'#FFEB3B', [1 235/255 59/255]};
            elseif lambda > 495e-9
                self.color = {'#B2FF59', [178/255 255/255 89/255]};
            elseif lambda > 476e-9
                self.color = {'#00ACC1', [0 172/255 193/255]};
            elseif lambda > 450e-9
                self.color = {'#2196F3', [33/255 150/255 243/255]};
            else
                self.color = {'#AB47BC', [171/255 71/255 188/255]};
            end
        end
        
        function update(self, lens_list)
            % After adding lenses, update the beam parameters of each beam segments based on the lens_lst
            for i = 1 : size(lens_list, 1)
                w1 = self.beam_segments(i, 1);
                z1 = self.beam_segments(i, 2);
                zR1 = self.beam_segments(i, 4);
                d1 = lens_list(i, 1) - z1;      % spacing between the beam waist and the position of the next lens
                [w2, zR2, d2] = gaussian_focusing(w1, zR1, d1, lens_list(i, 2));        % Call the gaussian_focusing function to calculate the beam parameters after the lens
                z2 = d2 + lens_list(i, 1);
                divg2 = w2 / zR2;
                self.beam_segments(i+1, :) = [w2, z2, divg2, zR2, lens_list(i, 1), lens_list(i, 2)];        % store the calculated beam parameters of the next segment into the beam_segments array
            end
        end

        function profile_gen(self)
            % generate the beam propagation profile between the origin and table_end of the optic table.
            if size(self.beam_segments, 1) == 1     % when no lenses are in the beam
                z = linspace(self.table.origin, self.table.table_end, 1000);
                w_p = 0.5 * self.beam_segments(1, 1) .* sqrt(1 + ((z - self.beam_segments(1, 2)) ./ self.beam_segments(1, 4)).^2);
            else        % when at least one lens is in the beam line
                z = linspace(self.table.origin, self.beam_segments(2, 5), 1000);
                w_p = 0.5 * self.beam_segments(1, 1) .* sqrt(1 + ((z - self.beam_segments(1, 2)) ./ self.beam_segments(1, 4)).^2);
                
                if size(self.beam_segments, 1) > 2      % when at least two lenses are in the beam line
                    for i = 2 : size(self.beam_segments, 1) - 1
                        z_seg = linspace(self.beam_segments(i, 5), self.beam_segments(i+1, 5), 1000);
                        w_p_seg = 0.5 * self.beam_segments(i, 1) .* sqrt(1 + ((z_seg - self.beam_segments(i, 2)) ./ self.beam_segments(i, 4)).^2);

                        z = [z z_seg];
                        w_p = [w_p w_p_seg];
                    end 
                end

                z_seg = linspace(self.beam_segments(end, 5), self.table.table_end, 1000);
                w_p_seg = 0.5 * self.beam_segments(end, 1) .* sqrt(1 + ((z_seg - self.beam_segments(end, 2)) ./ self.beam_segments(end, 4)).^2);
                z = [z z_seg];
                w_p = [w_p w_p_seg];
                self.profile.radius = w_p;      % store the radius profile into the profile.radius array
                self.profile.z = z;     % store the propagation direction sampling into the profile.z array 
            end
        end

        function add_to(self, optic_table)
            % add the beam to the optic_table
            if isempty(optic_table.gaussian_beam)
                optic_table.gaussian_beam = self;
                self.table = optic_table;
            else
                disp('There is already a beam on the table!') 
            end
        end
    end
end