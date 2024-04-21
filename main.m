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
% % % Define the ranges for the parameters
% % scenarioNumbers = [1, 2, 3];
% % patientsPerIntervals = [3, 4, 5];
% % appointmentsInterval = 26:1:37;
% % endBuffers = 0:10:50; % From 0 to 50 in steps of 10 minutes
% % 
% % numExperiments = 30; % Number of experiments per parameter set
% % 
% % % Calculate the total number of combinations
% % totalCombinations = numel(scenarioNumbers) * numel(patientsPerIntervals) * ...
% %                     numel(appointmentsInterval) * numel(endBuffers);
% % 
% % % Preallocate the table with default values
% % resultsTable = table('Size', [totalCombinations, 10], ...
% %                      'VariableTypes', {'int32', 'int32', 'int32', 'int32', 'double', 'double', ...
% %                                        'double', 'double', 'double', 'double'}, ...
% %                      'VariableNames', {'Scenario', 'PatientsPerInterval', 'EndBuffer', ...
% %                                        'AppointmentInterval', ...
% %                                        'AVGTreatedPatientsCount'...
% %                                        'AverageWaitingTime', ...
% %                                        'Doctor1Utilization', 'Doctor2Utilization', ...
% %                                        'Doctor3Utilization', 'Doctor4Utilization'});
% % 
% % % Keep track of the current row
% % currentRow = 1;
% % 
% % % Loop over all combinations of parameters
% % for scenario = scenarioNumbers
% %     for patientsPerInterval = patientsPerIntervals
% %         for appointmentInterval = appointmentsInterval
% %             for endBuffer = endBuffers
% %                 disp([scenario,patientsPerInterval,appointmentInterval,endBuffer]);
% %                 % Set up parameters for this combination
% %                 params = struct('numDoctors', 4, 'totalSimulationTime', 600, ...
% %                                 'scenarioNumber', scenario, 'patientsPerInterval', patientsPerInterval, ...
% %                                 'appointmentInterval', appointmentInterval, 'endBuffer', endBuffer);
% %                 priorities = [1, 2, 3, 4]; % Example priorities
% % 
% %                 % Initialize simulation manager
% %                 simManager = SimulationManager(numExperiments, params, 'minWorkload', priorities);
% %                 simManager.runExperiments();
% %                 simResults = simManager.getFinalResults();
% %                 avgTotalTreatedPatients = mean(simManager.getTotalTreatedPatients());
% % 
% %                 % Extract the utilization values
% %                 utilizationValues = num2cell(simResults(1).DoctorUtilizations); 
% % 
% %                 % Assign the results directly to the preallocated table
% %                 resultsTable(currentRow, :) = [{scenario}, {patientsPerInterval}, {endBuffer}, ...
% %                                                {appointmentInterval}, ...
% %                                                {avgTotalTreatedPatients}, ...
% %                                                {simResults(1).AverageWaitingTime}, utilizationValues(:)'];
% % 
% %                 % Increment the row counter
% %                 currentRow = currentRow + 1;
% %             end
% %         end
% %     end
% % end
% % 
% % % Save the results to a CSV file
% % writetable(resultsTable, 'SimulationResults.csv');  % Saving the full results
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
    1, 4, 0, 35;
    2, 3, 0, 31;
    2, 5, 0, 31;
    2, 4, 0, 31;
    2, 3, 20, 30;
    3, 3, 0, 26;
    2, 5, 20, 36;
    3, 3, 0, 31;
    3, 3, 30, 29;
    2, 3, 20, 36;
    2, 4, 40, 35;
    2, 5, 30, 30;
    2, 3, 30, 30;
    1, 4, 30, 35;
    2, 4, 30, 31;
    2, 3, 30, 31;
    1, 3, 40, 26;
    1, 3, 30, 26;
    2, 5, 40, 31;
    2, 3, 40, 31;
    2, 4, 40, 31;
];


numExperiments = 200;  % Adjust the number of experiments as necessary

resultsTable = table('Size', [21, 10], ...
                     'VariableTypes', {'int32', 'int32', 'int32', 'int32', 'double', 'double', ...
                                       'double', 'double', 'double', 'double'}, ...
                     'VariableNames', {'Scenario', 'PatientsPerInterval', 'EndBuffer', ...
                                       'AppointmentInterval', ...
                                       'AVGTreatedPatientsCount'...
                                       'AverageWaitingTime', ...
                                       'Doctor1Utilization', 'Doctor2Utilization', ...
                                       'Doctor3Utilization', 'Doctor4Utilization'});
currentRow = 1;

% Loop over all rows of parameters
for i = 1:size(data, 1)
    scenario = data(i, 1);
    patientsPerInterval = data(i, 2);
    endBuffer = data(i, 3);
    appointmentInterval = data(i, 4);
    
    % Set up parameters for this combination
    params = struct('numDoctors', 4, 'totalSimulationTime', 600, ...
                    'scenarioNumber', scenario, 'patientsPerInterval', patientsPerInterval, ...
                    'appointmentInterval', appointmentInterval, 'endBuffer', endBuffer);
    priorities = [1, 2, 3, 4]; % Example priorities

    % Initialize simulation manager
    simManager = SimulationManager(numExperiments, params, 'minWorkload', priorities);
    simManager.runExperiments();
    simResults = simManager.getFinalResults();
    avgTotalTreatedPatients = mean(simManager.getTotalTreatedPatients());

    % Extract the utilization values
    utilizationValues = num2cell(simResults(1).DoctorUtilizations); 

    % Assign the results directly to the preallocated table
    resultsTable(currentRow, :) = [{scenario}, {patientsPerInterval}, {endBuffer}, ...
                                   {appointmentInterval}, ...
                                   {avgTotalTreatedPatients}, ...
                                   {simResults(1).AverageWaitingTime}, utilizationValues(:)'];

    % Store results
    currentRow = currentRow + 1;
end

writetable(resultsTable, '200RunsFinal.csv');

