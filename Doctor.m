classdef Doctor < handle
    properties
        id;
        isBusy = false;               % Indicates if the doctor is currently busy
        currentPatient = Patient.empty;  % The patient currently being treated, if any
        totalWorkingTime = 0; % Total minutes spent treating patients
    end
    methods
        function obj = Doctor()
            obj.id = Doctor.getNextId(); % Assign and increment ID
        end

        function obj = treatPatient(obj, patient, currentTime)
            obj.isBusy = true;
            obj.currentPatient = patient;
            patient.startTime = currentTime;
            patient.waitingTime = patient.startTime - patient.arrivalTime;

            % Determine treatment duration based on whether there are complications
            treatmentDuration = randi([20, 30]);  % Standard treatment time in minutes
            if(patient.hasComplication)
                treatmentDuration = randi([40, 60]); % Extended time if complication occured
            end
            patient.departureTime = currentTime + treatmentDuration;
            obj.totalWorkingTime = obj.totalWorkingTime + (patient.departureTime - currentTime);
        end
        function obj = finishTreatment(obj)
            obj.isBusy = false;
            obj.currentPatient = Patient.empty;  % Clear the current patient
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
