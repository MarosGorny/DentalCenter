clc;
clear functions;

% Create a clinic instance with doctors and totalSimulationTime
%myClinic = Clinic(1,6*60);
myClinic = Clinic(0,120);
            %Scenario 1, 3 patients, every 30 min, with 0 endbuffer
            %myClinic.generateScheduledArrivals(1,3,30,0);

            %Scenario 2, alternating patients 4 and 3, every 30 min, 
            % with 0 endbuffer           
            %myClinic.generateScheduledArrivals(2,-1,30,0);

            %Scenario 3, Patients arrive every 10 minutes within a
            % 30-minute interval, with 0 end buffer
            myClinic.generateScheduledArrivals(3, 3, 50,0);  

myClinic.runSimulation();

clear functions;
