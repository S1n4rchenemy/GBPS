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
            self.beam_color();
        end
        
        function update(self, lens_list)
            % After adding lenses, update the beam parameters of each beam segments based on the lens_lst
            self.beam_segments(2:end, :) = [];    
            if ~isempty(lens_list)
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
        end

        function profile_gen(self)
            % generate the beam propagation profile between the origin and table_end of the optic table.
            if size(self.beam_segments, 1) == 1     % when no lenses are in the beam
                z = linspace(self.table.origin, self.table.table_end, 1000);
                w_p = 0.5 * self.equation(z, 1);
            else        % when at least one lens is in the beam line
                z = linspace(self.table.origin, self.beam_segments(2, 5), 1000);
                w_p = 0.5 * self.equation(z, 1);
                
                if size(self.beam_segments, 1) > 2      % when at least two lenses are in the beam line
                    for i = 2 : size(self.beam_segments, 1) - 1
                        z_seg = linspace(self.beam_segments(i, 5), self.beam_segments(i+1, 5), 1000);
                        w_p_seg = 0.5 * self.equation(z_seg, i);

                        z = [z z_seg];
                        w_p = [w_p w_p_seg];
                    end 
                end

                z_seg = linspace(self.beam_segments(end, 5), self.table.table_end, 1000);
                w_p_seg = 0.5 * self.equation(z_seg, size(self.beam_segments, 1));
                z = [z z_seg];
                w_p = [w_p w_p_seg];
            end
            self.profile.radius = w_p;      % store the radius profile into the profile.radius array
            self.profile.z = z;     % store the propagation direction sampling into the profile.z array 
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

        function beam_color(self)
            % determine the beam profile color based on its wavelength
            if self.lambda > 620e-9
                self.color = {'#F44336', [244/255 67/255 54/255]};
            elseif self.lambda > 590e-9
                self.color = {'#FB8C00', [251/255 140/255 0]};
            elseif self.lambda > 570e-9
                self.color = {'#FFEB3B', [1 235/255 59/255]};
            elseif self.lambda > 495e-9
                self.color = {'#B2FF59', [178/255 255/255 89/255]};
            elseif self.lambda > 476e-9
                self.color = {'#00ACC1', [0 172/255 193/255]};
            elseif self.lambda > 450e-9
                self.color = {'#2196F3', [33/255 150/255 243/255]};
            else
                self.color = {'#AB47BC', [171/255 71/255 188/255]};
            end
        end

        function change_to(self, new_lambda, new_M2, new_z0, new_waist)
            % change the beam initial parameters
            init_waist = self.beam_segments(1, 1);
            init_z0 = self.beam_segments(1, 2);
            if nargin > 1
                self.lambda = new_lambda;
                if nargin > 2
                    self.M2 = new_M2;
                    if nargin > 3
                        init_z0 = new_z0;
                        if nargin > 4
                            init_waist = new_waist;
                        end
                    end
                end
            end
            init_divg = 4 * self.M2 * self.lambda / pi / init_waist;
            init_zR = init_waist / init_divg;
            self.beam_segments(1, :) = [init_waist, init_z0, init_divg, init_zR, 0, 0];
            self.beam_color();

            if ~isempty(self.table)
                self.table.table_update();
            end
        end

        function remove(self)
            if ~isempty(self.table)
                self.table.remove_part(self)
            end
            % beam.profiel is not empty and still keeps the previous information
        end

        function w = size(self, z)
            index = 1;
            if size(self.beam_segments, 1) > 1
                for i = 2 : size(self.beam_segments, 1)
                    if z > self.beam_segments(i, 5)
                        index = i;
                        break
                    end
                end
            end

            w = self.equation(z, index); 
        end

        function w = equation(self, z, index)
            w0 = self.beam_segments(index, 1);
            z0 = self.beam_segments(index, 2);
            zR = self.beam_segments(index, 4);

            w = w0 * sqrt(1 + ((z - z0) / zR) .^ 2);
        end

    end
end