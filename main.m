clc;
clear functions;

params = struct('numDoctors', 4, 'totalSimulationTime', 600, ...
                'scenarioNumber', 1, 'patientsPerInterval', 3, ...
                'appointmentInterval', 30, 'endBuffer', 0);
priorities = [1 2 3 4];
simManager = SimulationManager(10, params,'minWorkLoad',priorities); % Run 10 experiments with the given parameters
simManager.runExperiments();
results = simManager.getFinalResults(); % Retrieve results as a structured array

% Optionally display the results
simManager.displayResults();



% Create a clinic instance with doctors and totalSimulationTime
%myClinic = Clinic(1,6*60);
% myClinic = Clinic(4,60);
%             %Scenario 1, 3 patients, every 30 min, with 0 endbuffer
%             myClinic.generateScheduledArrivals(1,4,30,0);
% 
%             %Scenario 2, alternating patients 4 and 3, every 30 min, 
%             % with 0 endbuffer           
%             %myClinic.generateScheduledArrivals(2,-1,30,0);
% 
%             %Scenario 3, Patients arrive every 10 minutes within a
%             % 30-minute interval, with 0 end buffer
%             %myClinic.generateScheduledArrivals(3, 3, 50,0);  
% 
% myClinic.runSimulation();
% stats = myClinic.getResults();
% myClinic.displayResults();

clear functions;
