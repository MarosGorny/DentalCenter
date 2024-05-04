% % % clc;
% % % clear functions;
% % % 
% % % params = struct('numDoctors', 4, 'totalSimulationTime', 600, ...
% % %                 'scenarioNumber', 1, 'patientsPerInterval', 3, ...
% % %                 'appointmentInterval', 30, 'endBuffer', 0);
% % % priorities = [1 2 3 4];
% % % simManager = SimulationManager(2, params,'minWorkload',priorities); % Run 10 experiments with the given parameters
% % % simManager.runExperiments();
% % % results = simManager.getFinalResults(); % Retrieve results as a structured array
% % % 
% % % %VYSLEDKYYYYY
% % % mean(simManager.getTotalTreatedPatients())
% % % mean(simManager.getDoctorsUtilization(),2)
% % % results(1).AverageWaitingTime
% % % 
% % % % Optionally display the results
% % % %simManager.displayResults();
% % % 
% % % clear functions;
% % 
% % 
% % 
% % 
% % 
% % 
%Define the ranges for the parameters
% scenarioNumbers = [3];
% patientsPerIntervals = [3, 4, 5, 6];
% appointmentsInterval = 24:2:40;
% endBuffers = 0:15:60; % From 0 to 60 in steps of 15 minutes
% 
% numExperiments = 200; % Number of experiments per parameter set
% 
% % Calculate the total number of combinations
% totalCombinations = numel(scenarioNumbers) * numel(patientsPerIntervals) * ...
%                     numel(appointmentsInterval) * numel(endBuffers);
% 
% % Preallocate the table with default values
% resultsTable = table('Size', [totalCombinations, 10], ...
%                      'VariableTypes', {'int32', 'int32', 'int32', 'int32', 'double', 'double', ...
%                                        'double', 'double', 'double', 'double'}, ...
%                      'VariableNames', {'Scenario', 'PatientsPerInterval', 'EndBuffer', ...
%                                        'AppointmentInterval', ...
%                                        'AVGTreatedPatientsCount'...
%                                        'AverageWaitingTime', ...
%                                        'Doctor1Utilization', 'Doctor2Utilization', ...
%                                        'Doctor3Utilization', 'Doctor4Utilization'});
% 
% % Extend the preallocated table with two new columns for CI
% resultsTable = [resultsTable, ...
%     table('Size', [totalCombinations, 2], ...
%           'VariableTypes', {'double', 'double'}, ...
%           'VariableNames', {'LowerCI', 'UpperCI'})];
% 
% % Keep track of the current row
% currentRow = 1;
% 
% % Loop over all combinations of parameters
% for endBuffer = endBuffers
%     for appointmentInterval = appointmentsInterval
%         for scenario = scenarioNumbers
%             % Adjust the loop over patientsPerInterval based on the scenario
%             if scenario == 2
%                 % Only run once for scenario 2
%                 tempPatientsPerIntervals = patientsPerIntervals(1);
%             else
%                 % Run for all patient intervals for other scenarios
%                 tempPatientsPerIntervals = patientsPerIntervals;
%             end
% 
%             for patientsPerInterval = tempPatientsPerIntervals
%                 disp([scenario,patientsPerInterval,appointmentInterval,endBuffer]);
%                 % Set up parameters for this combination
%                 params = struct('numDoctors', 4, 'totalSimulationTime', 360, ...
%                                 'scenarioNumber', scenario, 'patientsPerInterval', patientsPerInterval, ...
%                                 'appointmentInterval', appointmentInterval, 'endBuffer', endBuffer);
%                 priorities = [1, 2, 3, 4]; % Example priorities
% 
%                 % Initialize simulation manager
%                 simManager = SimulationManager(numExperiments, params, 'minWorkload', priorities);
%                 simManager.runExperiments();
%                 simResults = simManager.getFinalResults();
%                 avgTotalTreatedPatients = mean(simManager.getTotalTreatedPatients());
% 
%                 % Get results including the raw data for CI calculation
%                 averageWaitingTimes = simManager.getAverageWaitingTimeForAllRuns();
%                 avgWaitingTime = mean(averageWaitingTimes);
%                 stdDevWaitingTime = std(averageWaitingTimes);
%                 numExperiments = length(averageWaitingTimes);
%                 ciWidth = 1.96 * (stdDevWaitingTime / sqrt(numExperiments));
%                 lowerCI = avgWaitingTime - ciWidth;
%                 upperCI = avgWaitingTime + ciWidth;
% 
%                 % Extract the utilization values
%                 utilizationValues = num2cell(simResults(1).DoctorUtilizations); 
% 
%                 % Assign the results directly to the preallocated table
%                 resultsTable(currentRow, :) = [{scenario}, {patientsPerInterval}, {endBuffer}, ...
%                                                {appointmentInterval}, ...
%                                                {avgTotalTreatedPatients}, ...
%                                                {simResults(1).AverageWaitingTime}, utilizationValues(:)', ...
%                                                {lowerCI}, {upperCI}];
% 
%                 % Increment the row counter
%                 currentRow = currentRow + 1;
%             end
%         end
%     end
% end
% 
% % Save the results to a CSV file
% writetable(resultsTable, 'SimulationResults.csv');  % Saving the full results
% disp("ENDDDDDDDDDDDDDD!!!!!!!!!!!!!!!!!!!!!!!!!")


% % 
% % % Filter results based on criteria
% % optimalResults = resultsTable(resultsTable.AverageWaitingTime < 10 & ...
% %                               resultsTable.Doctor1Utilization < 100 & ...
% %                               resultsTable.Doctor1Utilization > 80 & ...
% %                               resultsTable.Doctor2Utilization < 100 & ...
% %                               resultsTable.Doctor2Utilization > 80 & ...
% %                               resultsTable.Doctor3Utilization < 100 & ...
% %                               resultsTable.Doctor3Utilization > 80 & ...
% %                               resultsTable.Doctor4Utilization < 100 & ...
% %                               resultsTable.Doctor4Utilization > 80, :);
% % 
% % 
% % % Save the optimal results to a CSV file
% % writetable(optimalResults, 'OptimalSimulationResults.csv');  % Saving only the filtered optimal results
% % % disp("ENDDDDDDDDDDDDDD!!!!!!!!!!!!!!!!!!!!!!!!!")




data = [
    1, 3, 0, 28;
    2, 3, 0, 34;
    3, 4, 0, 38;
    1, 3, 15, 28;
    2, 3, 15, 34;
    3, 3, 15, 28;
    1, 4, 30, 38;
    3, 3, 30, 28;
    2, 3, 30, 34;
    1, 3, 0, 38;
    3, 3, 0, 38;
    1, 3, 15, 36;
    3, 3, 15, 36;
    1, 3, 30, 34;
    3, 3, 30, 34;
    1, 3, 45, 34;
    3, 3, 45, 32;
    2, 3, 45, 40;
    1, 3, 60, 32;
    3, 3, 60, 32;
    2, 3, 60, 40
];

numExperiments = 5000;  % Adjust the number of experiments as necessary

resultsTable = table('Size', [21, 10], ...
                     'VariableTypes', {'int32', 'int32', 'int32', 'int32', 'double', 'double', ...
                                       'double', 'double', 'double', 'double'}, ...
                     'VariableNames', {'Scenario', 'PatientsPerInterval', 'EndBuffer', ...
                                       'AppointmentInterval', ...
                                       'AVGTreatedPatientsCount'...
                                       'AverageWaitingTime', ...
                                       'Doctor1Utilization', 'Doctor2Utilization', ...
                                       'Doctor3Utilization', 'Doctor4Utilization'});

% Extend the preallocated table with two new columns for CI
resultsTable = [resultsTable, ...
    table('Size', [21, 2], ...
          'VariableTypes', {'double', 'double'}, ...
          'VariableNames', {'LowerCI', 'UpperCI'})];

currentRow = 1;

% Loop over all rows of parameters
for i = 1:size(data, 1)
    scenario = data(i, 1);
    patientsPerInterval = data(i, 2);
    endBuffer = data(i, 3);
    appointmentInterval = data(i, 4);

    % Set up parameters for this combination
    params = struct('numDoctors', 4, 'totalSimulationTime', 360, ...
                    'scenarioNumber', scenario, 'patientsPerInterval', patientsPerInterval, ...
                    'appointmentInterval', appointmentInterval, 'endBuffer', endBuffer);
    priorities = [1, 2, 3, 4]; % Example priorities

    % Initialize simulation manager
    simManager = SimulationManager(numExperiments, params, 'minWorkload', priorities);
    simManager.runExperiments();
    simResults = simManager.getFinalResults();
    avgTotalTreatedPatients = mean(simManager.getTotalTreatedPatients());

     % Get results including the raw data for CI calculation
    averageWaitingTimes = simManager.getAverageWaitingTimeForAllRuns();
    avgWaitingTime = mean(averageWaitingTimes);
    stdDevWaitingTime = std(averageWaitingTimes);
    numExperiments = length(averageWaitingTimes);
    ciWidth = 1.96 * (stdDevWaitingTime / sqrt(numExperiments));
    lowerCI = avgWaitingTime - ciWidth;
    upperCI = avgWaitingTime + ciWidth;

    % Extract the utilization values
    utilizationValues = num2cell(simResults(1).DoctorUtilizations); 

    % Assign the results directly to the preallocated table
    resultsTable(currentRow, :) = [{scenario}, {patientsPerInterval}, {endBuffer}, ...
                                   {appointmentInterval}, ...
                                   {avgTotalTreatedPatients}, ...
                                   {simResults(1).AverageWaitingTime}, utilizationValues(:)', ...
                                   {lowerCI}, {upperCI}];

    % Store results
    currentRow = currentRow + 1;
end

writetable(resultsTable, '5000RunsFinal.csv');

