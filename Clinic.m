classdef Clinic < handle
    properties (Access = public)
        doctors;
        regularQueue = [];
        urgentQueue = [];
        clinicEvents = Event.empty; % Array of events
        patients = []; % Array to store all patients for statistics

        currentTime = 0;
        totalSimulationTime;
        
        statsManager;

    end
    methods
        function obj = Clinic(numDoctors,totalSimulationTime)
            
            obj.totalSimulationTime = totalSimulationTime;
            obj.doctors = Doctor.empty(numDoctors, 0); % Initialize an empty array of Doctor objects
            obj.statsManager = StatisticsManager(numDoctors);

            for i = 1:numDoctors
                obj.doctors(i) = Doctor(); % Create a new Doctor instance for each element
            end

            % Initialize the simulation by generating the first arrival
            obj.currentTime = 0;  % Start time of the clinic operation
            %obj = obj.generateNextArrival();  % Schedule the first patient arrival

            % Add random urgent patients
            urgentPatientsCount = 0;% randi([6, 10]);
           urgentTimes = sort(randi(totalSimulationTime-1, urgentPatientsCount, 1));

            for i = 1:urgentPatientsCount
                urgentPatient = Patient(urgentTimes(i), true);
                urgentEvent = Event.createArrival(urgentTimes(i), urgentPatient);
                obj.clinicEvents = [obj.clinicEvents, urgentEvent];
            end

            % Sort events after adding urgent patients
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);

        end

        function obj = runSimulation(obj)

            while ~isempty(obj.clinicEvents)
                % Get the next event
                nextEvent = obj.clinicEvents(1);
                obj.clinicEvents(1) = []; % Remove the event from the queue
            
                if (nextEvent.time >= obj.totalSimulationTime)
                    if (strcmp(nextEvent.type, 'arrival'))
                        % Change currentTime, but don't handle the event.
                        obj.currentTime = nextEvent.time;
                    else
                        % Change currentTime, and handle the endTreatmentEvent
                        obj.currentTime = nextEvent.time;
                        obj.eventHandler(nextEvent);
                    end
                else
                    obj.currentTime = nextEvent.time;
            
                    % Handle the event based on its type
                    obj.eventHandler(nextEvent);
                end
            end
        end

        function obj = eventHandler(obj, event)

            switch event.type
                case 'arrival'                    
                    disp(['Patient ',num2str(event.patient.id) ,' arrived at ', num2str(event.patient.arrivalTime)]);
                    if(event.patient.isUrgent)
                        disp("   URGENT!!!")
                    end
                    obj = obj.handleArrival(event.patient);
                                        obj.statsManager.logQueueLength(obj.currentTime,length(obj.regularQueue) + length(obj.urgentQueue));
                case 'startTreatment'
                    
                    event.doctor = event.doctor.treatPatient(event.patient, obj.currentTime);
                    obj.statsManager.logWaitingTime(event.patient.waitingTime);                   
                    disp(['Doctor ',  int2str(int64(event.doctor.id)), ' started treatment at ', num2str(obj.currentTime)]);
                    disp(['   PatientID:',int2str(int64(event.patient.id)), ' TT: ', int2str(event.patient.departureTime - event.patient.startTime), '   C: ',  int2str(int8(event.patient.hasComplication))]);
                    if(event.patient.isUrgent)
                        disp("   URGENT!!!")
                    end

                    endTreatmentEvent = Event.createEndTreatment(event.patient.departureTime, event.patient, event.doctor);
                    obj.clinicEvents = [obj.clinicEvents, endTreatmentEvent];
                    obj.statsManager.logQueueLength(obj.currentTime,length(obj.regularQueue) + length(obj.urgentQueue));
                case 'endTreatment'
                    
                    disp(['Doctor ', num2str(event.doctor.id), ' finished treatment at ', num2str(obj.currentTime)]);
                    event.doctor = event.doctor.finishTreatment();

                    if ~isempty(obj.urgentQueue)
                        nextPatient = obj.urgentQueue(1);
                        obj.urgentQueue(1) = [];  % Remove this patient from the urgent queue
                    elseif ~isempty(obj.regularQueue)
                        nextPatient = obj.regularQueue(1);
                        obj.regularQueue(1) = [];  % Remove this patient from the regular queue
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

            % Resort events as needed or after insertion
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);
        end

        function obj = handleArrival(obj, patient)
            % Select strategy: 'random', 'priority', 'circular', or 'minWorkload'
            strategy = 'minWorkload';  % Change as needed
            [freeDoctor, doctorIndex] = obj.assignDoctor(strategy);

            if isempty(freeDoctor)
                % Sort patients into appropriate queues
                if patient.isUrgent
                    obj.urgentQueue = [obj.urgentQueue, patient];  % Add urgent patient to urgent queue
                else
                    obj.regularQueue = [obj.regularQueue, patient];  % Add regular patient to regular queue
                end
            else
               % If a doctor is available, start treatment immediately
                startTreatmentEvent = Event.createStartTreatment(obj.currentTime, patient, obj.doctors(doctorIndex));
                obj.eventHandler(startTreatmentEvent);

            end
        
            % Generate the next arrival event for non urgent patient
            if ~patient.isUrgent
                %In scenarios we dont need nextArrival
                %obj = obj.generateNextArrival();
            end

            obj.patients = [obj.patients, patient]; % Add patient to the list for tracking
        end


        function obj = generateNextArrival(obj)
            % Calculate the time for the next patient's arrival
            interArrivalTime = 25;  % Assuming fixed inter-arrival time for simplicity
            nextArrivalTime = obj.currentTime + interArrivalTime;

            if(nextArrivalTime < obj.totalSimulationTime)
                % Create the next patient
                nextPatient = Patient(nextArrivalTime);
            
                % Create an arrival event for the next patient using the Event class method
                nextArrivalEvent = Event.createArrival(nextArrivalTime, nextPatient);
            
                % Add the event to the clinic's event queue
                obj.clinicEvents = [obj.clinicEvents, nextArrivalEvent];  
            end
        end

        function obj = generateScheduledArrivals(obj, scenarioNumber, patientsPerInterval, appointmentInterval, endBuffer)
            variability = 0; % +/- variability in minutes
    
            switch scenarioNumber
                case 1
                    % Scenario 1: Variable number of patients at variable intervals
                    finalArrivalTime = obj.totalSimulationTime - endBuffer;  % Calculate the time to stop new arrivals
                    for scheduledTime = 0:appointmentInterval:finalArrivalTime
                        for p = 1:patientsPerInterval
                            actualTime = scheduledTime + randi([-variability, variability], 1, 1);
                            if actualTime < finalArrivalTime
                                if actualTime < 0
                                    actualTime = 0;
                                end
                                patient = Patient(actualTime);
                                arrivalEvent = Event.createArrival(actualTime, patient);
                                obj.clinicEvents = [obj.clinicEvents, arrivalEvent];
                            end
                        end
                    end
               case 2
                    % Scenario 2: Alternating number of patients per interval
                    patientsAlternating = [4, 3];  % Array to alternate between 4 and 3 patients
                    finalArrivalTime = obj.totalSimulationTime - endBuffer;  % Calculate the time to stop new arrivals
                    for interval = 0:appointmentInterval:finalArrivalTime
                        % Determine number of patients for this interval
                        index = mod(interval / appointmentInterval, 2) + 1;  % Alternates between 1 and 2
                        numPatients = patientsAlternating(index);
        
                        for p = 1:numPatients
                            actualTime = interval + randi([-variability, variability], 1, 1);
                            if actualTime < finalArrivalTime
                                if actualTime < 0
                                    actualTime = 0;
                                end
                                patient = Patient(actualTime);
                                arrivalEvent = Event.createArrival(actualTime, patient);
                                obj.clinicEvents = [obj.clinicEvents, arrivalEvent];
                            end
                        end
                    end
            case 3
                % Scenario 3: Patients arrive evenly spaced within each interval
                finalArrivalTime = obj.totalSimulationTime - endBuffer;  % Calculate the time to stop new arrivals
                for interval = 0:appointmentInterval:finalArrivalTime
                    % Calculate the sub-interval for each patient
                    timeStep = appointmentInterval / patientsPerInterval;
    
                    for i = 0:patientsPerInterval-1
                        scheduledTime = interval + i * timeStep;
                        scheduledTime = round(scheduledTime);
                        actualTime = scheduledTime + randi([-variability, variability], 1, 1);
                        if actualTime < finalArrivalTime
                            if actualTime < 0
                                actualTime = 0;  % Adjust for negative time due to variability
                            end
                            patient = Patient(actualTime);
                            arrivalEvent = Event.createArrival(actualTime, patient);
                            obj.clinicEvents = [obj.clinicEvents, arrivalEvent];
                        end
                    end
                end
            end
        

    
        
            % Sort events after adding them
            [~, idx] = sort([obj.clinicEvents.time]);
            obj.clinicEvents = obj.clinicEvents(idx);
        end

        function [doctor, doctorIndex] = assignDoctor(obj, strategy)
            availableDoctors = find(~[obj.doctors.isBusy]);  % Indices of available doctors
            
            if isempty(availableDoctors)
                doctor = [];  % No doctor is available
                doctorIndex = [];  % No index to return
                return;
            end
            
            switch strategy
                case 'random'
                    % Randomly choose one of the available doctors
                    idx = randi(length(availableDoctors));
                    doctorIndex = availableDoctors(idx);
                    doctor = obj.doctors(doctorIndex);
                
                case 'priority'
                    % Sorting available doctors by priority (highest first) and pick the first one
                    [~, idx] = sort([obj.doctors(availableDoctors).priority], 'descend');
                    doctorIndex = availableDoctors(idx(1));
                    doctor = obj.doctors(doctorIndex);
                
                case 'circular'
                    % Circular selection from available doctors
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
                    doctor = [];  % Error case, no doctor
                    doctorIndex = [];  % Error case, no index
            end
        end
        
                        

        function displayStatistics(obj)
            % Calculate and display the average waiting time
            totalWaitingTime = sum([obj.patients.waitingTime]);
            averageWaitingTime = totalWaitingTime / numel(obj.patients);
            disp(['Average Waiting Time: ', num2str(averageWaitingTime), ' minutes']);
        
            % Calculate and display the utilization for each doctor
            for i = 1:numel(obj.doctors)
                utilizationPercentage = (obj.doctors(i).totalWorkingTime / obj.totalSimulationTime) * 100;
                disp(['Doctor ', num2str(obj.doctors(i).id), ' Utilization: ', num2str(utilizationPercentage), '%']);
            end
        end

        function displayResults(obj)
            for i = 1:numel(obj.doctors)
                 obj.statsManager.updateDoctorUtilization(obj.doctors(i).id, obj.doctors(i).totalWorkingTime)

            end            
           

            obj.statsManager.displayStatistics(obj.totalSimulationTime);
        end

    end
end
