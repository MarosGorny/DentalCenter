classdef Patient < handle
    % Patient represents a patient within a healthcare simulation system.
    % This class handles patient properties including ID, arrival, and 
    % departure times, as well as tracking whether a patient has complications
    % or is considered an urgent case.

    properties
        id;                % Unique identifier for the patient
        arrivalTime;       % Time the patient arrives at the clinic
        startTime;         % Time the patient's treatment begins
        waitingTime;       % Time spent waiting for treatment
        departureTime;     % Time the patient's treatment finishes
        hasComplication = false;  % Indicates if the treatment involves complications
        isUrgent = false;         % Indicates if the patient is an urgent case
    end

    methods
        function obj = Patient(arrivalTime, id, isUrgent)
            % Constructor for creating a new Patient instance.
            % Inputs:
            %   arrivalTime - Time the patient arrives at the clinic
            %   isUrgent    - Boolean flag indicating if the case is urgent
            %   id          - Id of the Patient
            obj.id = id; 
            
            if nargin < 3
                isUrgent = false;  % Default is not urgent
            end

            obj.arrivalTime = arrivalTime;
            obj.isUrgent = isUrgent;

            % Randomly determine if there are complications
            if rand() < 0.2  % Assuming 20% chance of complications
                obj.hasComplication = true;
            end
        end
    end
end
