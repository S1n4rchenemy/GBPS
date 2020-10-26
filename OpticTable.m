classdef OpticTable < handle
    properties 
        origin = 0;     % origin of this one-dimensional optic table
        table_end = 0;      % end of this one-dimensional optic table
        gaussian_beam = Beam.empty      % the gaussian beam on the table
        lenses = Lens.empty     % object array of the lenses on the table
    end

    methods
        function add_beam(self, beam)
            % add a beam to the optic table
            if ~isa(beam, 'Beam')
                disp('The argument has to be a gaussian beam!')
            else
                beam.add_to(self)
                self.origin = self.gaussian_beam.beam_segments(1, 2) - 1.5 * self.gaussian_beam.beam_segments(1, 4);        % determine the initial origin of the optic table based on the beam parameters
                self.table_end = self.gaussian_beam.beam_segments(1, 2) + 1.5 * self.gaussian_beam.beam_segments(1, 4);     % determine the initial table_end of the optic table based on the beam parameters
                self.gaussian_beam.profile_gen();       % generate the initial beam profile
            end
        end

        function add_lens(self, lens)
            % add a lens to the optic table
            if ~isa(lens, 'Lens')
                disp('Argument must be a lens!')
            end 
            self.lenses(length(self.lenses) + 1) = lens;        % update the lenses array
            lens.add_to(self);

            self.table_update();        % Call table_update method to update the optic table after adding this lens
        end

        function remove_part(self, part)
            % remove PART from the optic table
            if self.gaussian_beam == part
                part.table = OpticTable.empty;
                part.update([]);
                self.gaussian_beam = Beam.empty;
            elseif ismember(part, self.lenses)
                part.table = OpticTable.empty;
                self.lenses(self.lenses == part) = [];
                self.table_update()
            else
                disp('No such component on the optic table!')
            end
        end


        function table_update(self)
            % update the optic table origin and table_end, calculate the new beam parameters, and generate the new beam profile
            lens_list = self.lens_list_gen();
            if ~isempty(self.gaussian_beam)
                % call the update method of the gaussian beam to update the beam parameters
                self.gaussian_beam.update(lens_list);       

                % update the table origin and table_end
                init_z0 = self.gaussian_beam.beam_segments(1, 2);
                end_z0 = self.gaussian_beam.beam_segments(end, 2);
                if ~isempty(self.lenses)        
                    if init_z0 <= lens_list(1, 1)
                        self.origin = init_z0 - 4 * self.gaussian_beam.beam_segments(1, 4);
                    else
                        self.origin = lens_list(1, 1) - 2 * abs(lens_list(1, 2)); 
                    end
                    if end_z0 >= lens_list(end, 1)
                        self.table_end = end_z0 + 4 * self.gaussian_beam.beam_segments(end, 4);
                    else 
                        self.table_end = lens_list(end, 1) + 2 * abs(lens_list(end, 2));
                    end
                else
                    self.origin = init_z0 - 4 * self.gaussian_beam.beam_segments(1, 4);
                    self.table_end = end_z0 + 4 * self.gaussian_beam.beam_segments(end, 4);
                end

                % generate the new beam profile
                self.gaussian_beam.profile_gen();
            end
        end

        function plot_gen(self, range_z, range_radius)
            if isempty(self.gaussian_beam)
                disp('No beam on the table!')
            else 
                % set the axes limits based on the input arguments
                if nargin == 3
                    limits = [range_z range_radius];
                elseif nargin == 2
                    limits = [range_z [-inf inf]];
                else
                    limits = [-inf inf -inf inf];
                end  

                % For better illustration, extend the range of beam.profile if the plot range is larger than its current profile range 
                if nargin > 1
                    z_lb = limits(1);
                    z_ub = limits(2);
                    self.origin = min(z_lb, self.origin);
                    self.table_end = max(z_ub, self.table_end);
                    
                    self.gaussian_beam.profile_gen();
                end

                fig = figure;
                ax = axes(fig);

                % plot the beam profile by drawing two symmetric curves with the dependent as +waist_radius and -waist_radius
                %h = plot(ax, self.gaussian_beam.profile.z, self.gaussian_beam.profile.radius, self.gaussian_beam.profile.z, -1 .* self.gaussian_beam.profile.radius);
                %set(h, 'Color', self.gaussian_beam.color{1}, 'LineWidth', 1);

                % fill the area between two curves
                beam_area = [-1 * self.gaussian_beam.profile.radius, fliplr(self.gaussian_beam.profile.radius)];
                z2 = [self.gaussian_beam.profile.z, fliplr(self.gaussian_beam.profile.z)];
                patch(z2, beam_area, self.gaussian_beam.color{2})
                hold on

                % plot the vertical lines representing the thin lenses
                z_lens = kron(self.gaussian_beam.beam_segments(2:end, 5)', [1, 1]');
                plot(z_lens, repmat(ylim',1,size(z_lens,2)), 'k:', 'LineWidth', 1.5)

                axis(limits)
                
            end
        end

        function lens_list = lens_list_gen(self)
            % generate the a list containing the position and focal length of every lens, which is also sorted in ascending order based on the lens positions
            lens_list = double.empty(0, 2);
            if ~isempty(self.lenses)
                for i = 1 : length(self.lenses)
                    lens_list(i, :) = [self.lenses(i).pos self.lenses(i).f];        % lens position in the first column, lens focal length in the second column
                end
            end
            lens_list = sortrows(lens_list);        % sort the list in ascending order based on the lens positions
        end
    end
end