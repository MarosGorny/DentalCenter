classdef Patient < handle
    properties
        arrivalTime;          % Time the patient arrives
        startTime;            % Time treatment starts
        departureTime;        % Time treatment finishes
        hasComplication = false;  % Whether the treatment involves complications
    end
    methods
        function obj = Patient(arrivalTime)
            obj.arrivalTime = arrivalTime;
            % Randomly determine if there are complications
            if rand() < 0.2  % Assuming 20% chance of complications
                obj.hasComplication = true;
            end
        end
    end
end
