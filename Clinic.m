classdef Clinic < handle
    properties (Access = public)
        doctors;
        patientQueue = [];
        clinicEvents = Event.empty; % Array of events
        currentTime = 0;
    end
    methods
        function obj = Clinic(numDoctors)
            
            obj.doctors = Doctor.empty(numDoctors, 0); % Initialize an empty array of Doctor objects

            for i = 1:numDoctors
                obj.doctors(i) = Doctor(); % Create a new Doctor instance for each element
            end

            % Initialize the simulation by generating the first arrival
            obj.currentTime = 0;  % Start time of the clinic operation
            obj = obj.generateNextArrival();  % Schedule the first patient arrival
        end

        function obj = runSimulation(obj, totalSimulationTime)
            while ~isempty(obj.clinicEvents) && obj.clinicEvents(1).time <= totalSimulationTime
                
                % Get the next event
                nextEvent = obj.clinicEvents(1);
                obj.clinicEvents(1) = []; % Remove the event from the queue
                obj.currentTime = nextEvent.time;

                % Handle the event based on its type
                obj.eventHandler(nextEvent);
            end
        end

        function obj = eventHandler(obj, event)
            switch event.type
                case 'arrival'
                    obj = obj.handleArrival(event.patient);
                    disp(['Patient ',num2str(event.patient.id) ,' arrived at ', num2str(event.patient.arrivalTime)]);
                case 'startTreatment'
                    event.doctor = event.doctor.treatPatient(event.patient, obj.currentTime);
                    disp(['Doctor ',  int2str(int64(event.doctor.id)), ' started treatment at ', num2str(obj.currentTime)]);
                    disp(['   PatientID:',int2str(int64(event.patient.id)), ' TT: ', int2str(event.patient.departureTime - event.patient.startTime), '   C: ',  int2str(int8(event.patient.hasComplication))]);

                    endTreatmentEvent = Event.createEndTreatment(event.patient.departureTime, event.patient, event.doctor);
                    obj.clinicEvents = [obj.clinicEvents, endTreatmentEvent];
                case 'endTreatment'
                    event.doctor = event.doctor.finishTreatment();
                    disp(['Doctor ', num2str(event.doctor.id), ' finished treatment at ', num2str(obj.currentTime)]);
                    if ~isempty(obj.patientQueue)
                        nextPatient = obj.patientQueue(1);
                        obj.patientQueue(1) = [];  % Remove this patient from the queue
                        startTreatmentEvent = Event.createStartTreatment(obj.currentTime, nextPatient, event.doctor);
                        obj.clinicEvents = [obj.clinicEvents, startTreatmentEvent];
                    end                
                otherwise
                    error('Unknown event type');
            end

            % Resort events as needed or after insertion
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);
        end

        function obj = handleArrival(obj, patient)
            % Determine if a doctor is available or add to queue
            freeDoctor = find([obj.doctors.isBusy] == false, 1);
            if isempty(freeDoctor)
                obj.patientQueue = [obj.patientQueue, patient];
            else
                startTreatmentEvent = Event.createStartTreatment(obj.currentTime, patient, obj.doctors(freeDoctor));
                obj.clinicEvents = [obj.clinicEvents, startTreatmentEvent];        
            end
        
            % Generate the next arrival event
            obj = obj.generateNextArrival();
        end


        function obj = generateNextArrival(obj)
            % Calculate the time for the next patient's arrival
            interArrivalTime = 25;  % Assuming fixed inter-arrival time for simplicity
            nextArrivalTime = obj.currentTime + interArrivalTime;
        
            % Create the next patient
            nextPatient = Patient(nextArrivalTime);
        
            % Create an arrival event for the next patient using the Event class method
            nextArrivalEvent = Event.createArrival(nextArrivalTime, nextPatient);
        
            % Add the event to the clinic's event queue
            obj.clinicEvents = [obj.clinicEvents, nextArrivalEvent];        
        end
    end
end
