classdef Lens < handle
    properties
        f
        pos
        name
    end
    
    methods
        function self = Lens(f, pos)
            % constructor of the Lens class
            self.f = f;
            self.pos = pos;
            %self.name = name;
        end
    end
end