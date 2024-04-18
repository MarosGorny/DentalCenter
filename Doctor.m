classdef Doctor < handle
    properties
        isBusy = false;               % Indicates if the doctor is currently busy
        currentPatient = Patient.empty;  % The patient currently being treated, if any
    end
    methods
        function obj = treatPatient(obj, patient, currentTime)
            obj.isBusy = true;
            obj.currentPatient = patient;
            patient.startTime = currentTime;
             disp(['Doctor started treatment at ', num2str(currentTime)]);

            % Determine treatment duration based on whether there are complications
            treatmentDuration = 20;  % Standard treatment time in minutes
            if(patient.hasComplication)
                treatmentDuration = treatmentDuration + randi([20, 40]); % Additional time for complications
            end
            patient.departureTime = currentTime + treatmentDuration;
        end
        function obj = finishTreatment(obj)
            obj.isBusy = false;
            disp(['Doctor finished treatment at ', num2str(obj.currentPatient.departureTime)]);
            obj.currentPatient = Patient.empty;  % Clear the current patient
        end
    end
end
