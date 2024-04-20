classdef Doctor < handle
    % Doctor represents a healthcare provider in a simulation system.
    % This class manages doctor properties including availability, the
    % current patient being treated, and total working time.

    properties
        id;                 % Unique identifier for the doctor
        isBusy = false;     % Boolean indicating if the doctor is currently treating a patient
        currentPatient = Patient.empty;  % Current patient under treatment, if any
        totalWorkingTime = 0;  % Cumulative time spent treating patients, in minutes
        priority = 0;
    end

    methods
        function obj = Doctor(id)
            % Constructor for creating a new Doctor instance.
            % Input:
            %   id - Numerical ID for the doctor
            obj.id = id; % Assign the doctor ID based on the input
        end

        function obj = treatPatient(obj, patient, currentTime)
            % Method to start treatment for a patient.
            % Inputs:
            %   patient     - The patient object to be treated
            %   currentTime - The simulation time at which treatment starts

            obj.isBusy = true;
            obj.currentPatient = patient;
            patient.startTime = currentTime;
            patient.waitingTime = patient.startTime - patient.arrivalTime;

            % Determine treatment duration
            treatmentDuration = randi([20, 30]);  % Standard treatment time in minutes
            if patient.hasComplication
                treatmentDuration = randi([40, 60]); % Extended time for complications
            end
            patient.departureTime = currentTime + treatmentDuration;
            obj.totalWorkingTime = obj.totalWorkingTime + treatmentDuration;
        end

        function obj = finishTreatment(obj)
            % Method to mark the completion of a patient's treatment.
            obj.isBusy = false;
            obj.currentPatient = Patient.empty;  % Clear the current patient reference
        end
    end

    methods (Static)
        function id = getNextId()
            % Static method to retrieve the next unique ID for a new doctor.
            % Returns:
            %   id - A unique identifier for the doctor

            persistent nextId;
            if isempty(nextId)
                nextId = 1; % Initialize the first ID
            end
            id = nextId;
            nextId = nextId + 1; % Increment the ID for the next use
        end
    end
end
