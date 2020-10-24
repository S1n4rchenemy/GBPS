classdef Beam < handle
    properties
        lambda
        M2
        lens_list = double.empty(0, 2)
        beam_segments = double.empty(0, 4)
    end
    
    methods
        function self = Beam(lambda, waist, z0, M2)
            % constructor of a object of Beam class
            if nargin < 4
                self.M2 = 1;
            else
                self.M2 = M2;
            end
            
            self.lambda = lambda;
            init_divg = 4 * self.M2 * self.lambda / pi / waist;
            init_zR = waist / init_divg;
            self.beam_segments(1, :) = [waist, z0, init_divg, init_zR];
        end
        
        function add_lens(self, lens)
            % method for adding a lens to the beam
            if not(isa(lens, 'Lens'))
                disp('Argument must be a lens!')
            end                                                             % might need to consider the situation of lenses with the same positions
            self.lens_list = vertcat(self.lens_list, [lens.pos lens.f]);
            self.lens_list = sortrows(self.lens_list);
            % run the update funciton here
            self.update()
        end
        
        function update(self)
            % update the beam propagation profile based on the lens_lst
            for i = 1 : size(self.lens_list, 1)
                w1 = self.beam_segments(i, 1);
                z1 = self.beam_segments(i, 2);
                zR1 = self.beam_segments(i, 4);
                d1 = self.lens_list(i, 1) - z1;
                [w2, zR2, d2] = gaussian_focusing(w1, zR1, d1, self.lens_list(i, 2));
                z2 = d2 + self.lens_list(i, 1);
                divg2 = w2 / zR2;
                self.beam_segments(i+1, :) = [w2, z2, divg2, zR2];
            end
        end
        
        function [divg, zR] = prop_cal(self, waist)
            divg = self.M2 * self.lambda / pi / waist;
            zR = waist / divg;
        end
    end
end