classdef SimulationManager
    properties
        numExperiments;
        simulationParams;
    end
    
    methods
        function obj = SimulationManager(numExperiments, simulationParams)
            obj.numExperiments = numExperiments;
            obj.simulationParams = simulationParams;
        end
        
        function runExperiments(obj)
            for i = 1:obj.numExperiments
                fprintf('Running experiment %d\n', i);
                clinic = Clinic(obj.simulationParams.numDoctors, obj.simulationParams.totalSimulationTime);
                clinic.generateScheduledArrivals(obj.simulationParams.scenarioNumber, obj.simulationParams.patientsPerInterval, obj.simulationParams.appointmentInterval, obj.simulationParams.endBuffer);
                clinic.runSimulation();
                clinic.displayResults();
            end
        end
    end
end


% params = struct('numDoctors', 4, 'totalSimulationTime', 480, 'scenarioNumber', 1, 'patientsPerInterval', 3, 'appointmentInterval', 30, 'endBuffer', 30);
% simManager = SimulationManager(10, params); % Run 10 experiments with the given parameters
% simManager.runExperiments();