classdef Clinic < handle
    properties (Access = public)
        doctors;                    % Array of Doctor objects
        regularQueue = [];          % Queue for regular patients
        urgentQueue = [];           % Queue for urgent patients
        clinicEvents = Event.empty; % Dynamic array of Event objects
        patients = [];              % Array to store all patients for statistics

        currentTime = 0;            % Current time in the simulation
        totalSimulationTime;        % Total time for which the simulation runs
        
        statsManager;               % StatisticsManager object to handle stats
        information;

        patientSelectionMethod;
        totalTreatedPatients = 0;
    end

    methods
        function obj = Clinic(numDoctors, totalSimulationTime, patientSelection, doctorPriorities)
            % Constructor for Clinic class
            % Initialize an empty table with predefined variables
            obj.information = table(...
                'Size', [0, 7], ...
                'VariableTypes', {'int32', 'string', 'string', 'string', 'logical', 'logical', 'int32'}, ...
                'VariableNames', {'time', 'type', 'doctor', 'patient', 'complication', 'urgent', 'queueSize'});

            obj.patientSelectionMethod = patientSelection;

            obj.totalSimulationTime = totalSimulationTime;
            obj.doctors = Doctor.empty(numDoctors, 0);
            obj.statsManager = StatisticsManager(numDoctors);

            for i = 1:numDoctors
                obj.doctors(i) = Doctor(i);  % Initialize each doctor
                if(strcmp(patientSelection,'priority'))
                    obj.doctors(i).priority = doctorPriorities(i);
                end
            end

            % Schedule the arrival of urgent patients at randomized times
            urgentPatientsCount = randi([6, 10]);
            urgentTimes = sort(randi(totalSimulationTime - 1, urgentPatientsCount, 1));
            for i = 1:urgentPatientsCount
                urgentPatient = Patient(urgentTimes(i),-i, true);
                urgentEvent = Event.createArrival(urgentTimes(i), urgentPatient);
                obj.clinicEvents = [obj.clinicEvents, urgentEvent];
            end

            % Sort events by time after adding them
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);
        end

        function obj = runSimulation(obj)
            % Main simulation loop
            while ~isempty(obj.clinicEvents)
                nextEvent = obj.clinicEvents(1);
                obj.clinicEvents(1) = [];
                obj.currentTime = nextEvent.time;

                if nextEvent.time >= obj.totalSimulationTime && strcmp(nextEvent.type, 'arrival')
                    continue;  % Skip handling the event if its past simulation time
                else
                    obj.eventHandler(nextEvent);  % Process the event
                end
            end

            % Update statistics for each doctor after simulation ends
            for i = 1:numel(obj.doctors)
                obj.statsManager.updateDoctorUtilization(obj.doctors(i).id, obj.doctors(i).totalWorkingTime);
            end
        end

        function obj = eventHandler(obj, event)
            % Handle different types of events
            switch event.type
                case 'arrival'
                    newRow = {event.time,'Arrival','-', num2str(event.patient.id), event.patient.hasComplication, event.patient.isUrgent, length(obj.regularQueue) + length(obj.urgentQueue)};
                    obj.information = [obj.information; newRow];

                    obj.handleArrival(event.patient);
                    obj.statsManager.logQueueLength(obj.currentTime, length(obj.regularQueue) + length(obj.urgentQueue));

                case 'startTreatment'
                    event.doctor.treatPatient(event.patient, obj.currentTime);
                    obj.statsManager.logWaitingTime(event.patient.waitingTime);

                    newRow = {event.time,'StartTreatment',num2str(event.doctor.id), num2str(event.patient.id), event.patient.hasComplication, event.patient.isUrgent, length(obj.regularQueue) + length(obj.urgentQueue)};
                    obj.information = [obj.information; newRow];

                    endTreatmentEvent = Event.createEndTreatment(event.patient.departureTime, event.patient, event.doctor);
                    obj.clinicEvents = [obj.clinicEvents, endTreatmentEvent];
                    obj.statsManager.logQueueLength(obj.currentTime, length(obj.regularQueue) + length(obj.urgentQueue));

                case 'endTreatment'
                    newRow = {event.time,'EndTreatment',num2str(event.doctor.id), num2str(event.patient.id), event.patient.hasComplication, event.patient.isUrgent, length(obj.regularQueue) + length(obj.urgentQueue)};
                    obj.information = [obj.information; newRow];

                    event.doctor.finishTreatment();

                    obj.totalTreatedPatients = obj.totalTreatedPatients + 1;

                    % Check for next patient in queue
                    if ~isempty(obj.urgentQueue)
                        nextPatient = obj.urgentQueue(1);
                        obj.urgentQueue(1) = [];
                    elseif ~isempty(obj.regularQueue)
                        nextPatient = obj.regularQueue(1);
                        obj.regularQueue(1) = [];
                    else
                        nextPatient = [];
                    end

                    if ~isempty(nextPatient)
                        startTreatmentEvent = Event.createStartTreatment(obj.currentTime, nextPatient, event.doctor);
                        obj.clinicEvents = [obj.clinicEvents, startTreatmentEvent];
                    end
                otherwise
                    error('Unknown event type');
            end

            % Resort events if necessary
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);
        end

        function obj = handleArrival(obj, patient)
            % Determine strategy for assigning a doctor

            [freeDoctor, doctorIndex] = obj.assignDoctor(obj.patientSelectionMethod);

            if isempty(freeDoctor)
                if patient.isUrgent
                    obj.urgentQueue = [obj.urgentQueue, patient];  % Prioritize urgent patients
                else
                    obj.regularQueue = [obj.regularQueue, patient];
                end
            else
                % Assign the patient to the doctor, if available
                startTreatmentEvent = Event.createStartTreatment(obj.currentTime, patient, obj.doctors(doctorIndex));
                obj.eventHandler(startTreatmentEvent);
            end
        end

        function obj = generateScheduledArrivals(obj, scenarioNumber, patientsPerInterval, appointmentInterval, endBuffer)
            % Generates scheduled arrivals of patients based on different scenarios.
            % `scenarioNumber` determines the scheduling strategy,
            % `patientsPerInterval` defines how many patients arrive per interval,
            % `appointmentInterval` defines the time between patient groups,
            % `endBuffer` specifies a no-arrival period at the end of the simulation.
            
            variability = 10; % +/- variability in minutes
            id = 1;
        
            finalArrivalTime = obj.totalSimulationTime - endBuffer;  % Time after which no new patients are scheduled.
        
            switch scenarioNumber
                case 1
                    % Regular scheduling: a fixed number of patients at regular intervals.
                    for scheduledTime = 0:appointmentInterval:finalArrivalTime
                        for p = 1:patientsPerInterval
                            actualTime = max(0, scheduledTime + randi([-variability, variability], 1, 1)); % Ensure non-negative times.
                            if actualTime < finalArrivalTime
                                patient = Patient(actualTime,id);
                                id = id + 1;
                                arrivalEvent = Event.createArrival(actualTime, patient);
                                obj.clinicEvents = [obj.clinicEvents, arrivalEvent];
                            end
                        end
                    end
        
                case 2
                    % Alternating scheduling: alternating number of patients every interval.
                    patientsAlternating = [4, 3];  % Alternates between 4 and 3 patients.
                    for interval = 0:appointmentInterval:finalArrivalTime
                        index = mod(interval / appointmentInterval, 2) + 1; % Alternates between 1 and 2
                        numPatients = patientsAlternating(index);
        
                        for p = 1:numPatients
                            actualTime = max(0, interval + randi([-variability, variability], 1, 1));
                            if actualTime < finalArrivalTime
                                patient = Patient(actualTime,id);
                                id = id + 1;
                                arrivalEvent = Event.createArrival(actualTime, patient);
                                obj.clinicEvents = [obj.clinicEvents, arrivalEvent];
                            end
                        end
                    end
        
                case 3
                    % Evenly spaced scheduling: patients arrive at evenly spaced times within each interval.
                    for interval = 0:appointmentInterval:finalArrivalTime
                        timeStep = appointmentInterval / patientsPerInterval;
        
                        for i = 0:patientsPerInterval-1
                            scheduledTime = interval + i * timeStep;
                            actualTime = max(0, round(scheduledTime) + randi([-variability, variability], 1, 1));
                            if actualTime < finalArrivalTime
                                patient = Patient(actualTime,id);
                                id = id + 1;
                                arrivalEvent = Event.createArrival(actualTime, patient);
                                obj.clinicEvents = [obj.clinicEvents, arrivalEvent];
                            end
                        end
                    end
            end
        
            % Re-sort the event queue after adding new events
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);
        end     

        function [doctor, doctorIndex] = assignDoctor(obj, strategy)
            % Assign a doctor based on the specified strategy
            availableDoctors = find(~[obj.doctors.isBusy]);  % Indices of available doctors
            if isempty(availableDoctors)
                doctor = [];
                doctorIndex = [];
                return;
            end

            switch strategy
                case 'random'
                    idx = randi(length(availableDoctors));
                    doctorIndex = availableDoctors(idx);
                    doctor = obj.doctors(doctorIndex);

                case 'priority'
                    % Sorting available doctors by priority (highest first) and pick the first one
                    [~, idx] = sort([obj.doctors(availableDoctors).priority], 'descend');
                    doctorIndex = availableDoctors(idx(1));
                    doctor = obj.doctors(doctorIndex);

                case 'circular'
                    obj.lastAssignedDoctorIndex = mod(obj.lastAssignedDoctorIndex, length(availableDoctors)) + 1;
                    doctorIndex = availableDoctors(obj.lastAssignedDoctorIndex);
                    doctor = obj.doctors(doctorIndex);

                case 'minWorkload'
                    % Select the doctor with the minimum total working time
                    [~, idx] = min([obj.doctors(availableDoctors).totalWorkingTime]);
                    doctorIndex = availableDoctors(idx);
                    doctor = obj.doctors(doctorIndex);

                otherwise
                    error('Unknown doctor assignment strategy');
            end
        end

        function displayResults(obj)
            % Display the results of the simulation
            obj.statsManager.displayStatistics(obj.totalSimulationTime);
        end

        function info = getInformation(obj)
            info = obj.information;
        end

        function totalTreatedPatients = getTotalTreatedPatients(obj)
             totalTreatedPatients = obj.totalTreatedPatients;
        end

        function stats = getResults(obj)
            % Get the calculated statistics from the simulation
            stats = obj.statsManager.calculateStatistics(obj.totalSimulationTime);
        end
    end
end
