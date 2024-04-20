classdef SimulationManager < handle
    properties
        numExperiments;
        simulationParams;
        averageWaitingTimes; % Store average waiting times from each experiment
        doctorUtilizationsSums; % Sums of utilizations for averaging
        doctorCount; % Number of doctors
        finalAverageWaitingTime; % Final computed average waiting time
        finalDoctorUtilizations; % Final computed doctor utilizations

        finalQueueLengthHistory; % Store queue length histories from each experiment

        informationOfExperiments;

        selectionStrategy;
        priorites;
    end
    
    methods
        function obj = SimulationManager(numExperiments, simulationParams, selectionStrategy, priorites)
            obj.numExperiments = numExperiments;
            obj.simulationParams = simulationParams;
            obj.doctorCount = simulationParams.numDoctors;
            obj.averageWaitingTimes = zeros(1, numExperiments); % Preallocate for speed
            obj.doctorUtilizationsSums = zeros(obj.doctorCount, numExperiments); % Each column represents a doctor's total utilization across all experiments
            obj.finalQueueLengthHistory = cell(1, numExperiments); % Initialize as a cell array

            obj.informationOfExperiments = cell(1, numExperiments);
            obj.selectionStrategy = selectionStrategy;
            obj.priorites = priorites;
        end
        
        function runExperiments(obj)
            for i = 1:obj.numExperiments
                fprintf('Running experiment %d\n', i);
                clinic = Clinic(obj.simulationParams.numDoctors, obj.simulationParams.totalSimulationTime,obj.selectionStrategy,obj.priorites);
                clinic.generateScheduledArrivals(obj.simulationParams.scenarioNumber, obj.simulationParams.patientsPerInterval, obj.simulationParams.appointmentInterval, obj.simulationParams.endBuffer);
                clinic.runSimulation();

                %clinic.statsManager.displayStatistics(obj.simulationParams.totalSimulationTime);


                stats = clinic.getResults(); % Assuming getResults returns the statistics directly
                obj.informationOfExperiments{i} = clinic.getInformation();

                % Record the results
                obj.averageWaitingTimes(i) = stats.AverageWaitingTime;
                obj.doctorUtilizationsSums(:, i) = stats.DoctorUtilizations;
                obj.finalQueueLengthHistory{i} = stats.QueueLengthHistory; % Store each history in a cell
            end
            
            obj.calculateFinalResults();
        end
        
        function calculateFinalResults(obj)
            % Calculate the average of average waiting times
            obj.finalAverageWaitingTime = mean(obj.averageWaitingTimes);
            % Calculate the average of doctor utilizations across all experiments
            obj.finalDoctorUtilizations = mean(obj.doctorUtilizationsSums, 2);
        end
        
        function results = getFinalResults(obj)
            results = struct(...
                'AverageWaitingTime', obj.finalAverageWaitingTime, ...
                'DoctorUtilizations', obj.finalDoctorUtilizations, ...
                'QueueLengthHistory', obj.finalQueueLengthHistory ...
            );
            return;
        end

        function result = getDoctorsUtilization(obj)
            result = obj.doctorUtilizationsSums;
            return;
        end

        function information = getInformation(obj)
            information = obj.informationOfExperiments;
            return;
        end
        
        function setPriorities(obj, priorites)
            obj.priorites = priorites;
        end
        
        function displayResults(obj)
            % Displaying a header with experiment details
            fprintf('\n--- Simulation Summary ---\n');
            fprintf('Number of Experiments: %d\n', obj.numExperiments);
            fprintf('Total Simulation Time: %d minutes\n', obj.simulationParams.totalSimulationTime);
            fprintf('Number of Doctors: %d\n', obj.simulationParams.numDoctors);
            fprintf('Patients per Interval: %d\n', obj.simulationParams.patientsPerInterval);
            fprintf('Appointment Interval: %d minutes\n', obj.simulationParams.appointmentInterval);
            fprintf('End Buffer: %d minutes\n', obj.simulationParams.endBuffer);
            fprintf('Scenario Number: %d\n', obj.simulationParams.scenarioNumber);
            
            % Formatting and displaying average waiting time
            fprintf('\nAverage Waiting Time Across All Experiments: %.2f minutes\n', obj.finalAverageWaitingTime);
            
            % Displaying doctor utilizations
            fprintf('\nDoctor Utilizations:\n');
            for i = 1:obj.doctorCount
                fprintf('Doctor %d: %.2f%% Utilization\n', i, obj.finalDoctorUtilizations(i));
            end
            fprintf('--- End of Simulation Summary ---\n\n');
        end
    end
end

