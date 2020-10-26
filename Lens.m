classdef Lens < handle
    properties
        f       % focal length of the lens.  Positive for convex lens, negative for concave lens
        pos     % position of the lens
        %name
        table = OpticTable.empty        % optic table where the lens is added to
    end
    
    methods
        function self = Lens(f, pos)
            % constructor of the Lens class
            self.f = f;
            self.pos = pos;
            %self.name = name;
        end

        function add_to(self, optic_table)
            % add the lens to the optic_table
            self.table = optic_table;
        end

        function remove(self)
            % remove the lens from the optic table
            if ~isempty(self.table)
                self.table.remove_part(self)
            end
        end

        function move_to(self, new_pos)
            % move the lens to a new position, then update the optic table
            self.pos = new_pos;
            if ~isempty(self.table)
                self.table.table_update();
            end
        end

        function change_to(self, new_f)
            % change the focal length of the lens, then update the optic table
            self.f = new_f;
            if ~isempty(self.table)
                self.table.table_update();
            end
        end
    end
end