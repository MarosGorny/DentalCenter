classdef Patient < handle
    properties
        id;
        arrivalTime;          % Time the patient arrives
        startTime;            % Time treatment starts
        departureTime;        % Time treatment finishes
        hasComplication = false;  % Whether the treatment involves complications
        isUrgent = false;     % Whether the patient is an urgent case
    end

    methods
        function obj = Patient(arrivalTime, isUrgent)
            if nargin < 2
                isUrgent = false;  % Default is not urgent
            end

            obj.id = Patient.getNextId(); % Assign and increment ID
            obj.arrivalTime = arrivalTime;
            obj.isUrgent = isUrgent;

            % Randomly determine if there are complications
            if rand() < 0.2  % Assuming 20% chance of complications
                obj.hasComplication = true;
            end
        end
    end

    methods (Static)
        function id = getNextId()
            persistent nextId;
            if isempty(nextId)
                nextId = 1; % Initialize the first ID
            end
            id = nextId;
            nextId = nextId + 1; % Increment the ID for the next use
        end
    end
end
