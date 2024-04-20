classdef StatisticsManager < handle
    properties
        queueLengthHistory = []; % Stores pairs of [time, queueLength] to track queue length changes
        totalWaitingTime = 0;    % Sum of all waiting times to calculate the average
        totalPatients = 0;       % Count of all patients to calculate the average waiting time
        doctorUtilizations;      % Array to store total working time for each doctor
    end
    
    methods
        % Constructor to initialize the manager with the number of doctors
        function obj = StatisticsManager(numDoctors)
            obj.doctorUtilizations = zeros(numDoctors, 1);
        end
        
        % Logs the current queue length at a specific time
        function logQueueLength(obj, currentTime, queueLength)
            obj.queueLengthHistory = [obj.queueLengthHistory; [currentTime, queueLength]];
        end
        
        % Logs the waiting time for a patient to calculate the average later
        function logWaitingTime(obj, waitingTime)
            obj.totalWaitingTime = obj.totalWaitingTime + waitingTime;
            obj.totalPatients = obj.totalPatients + 1;
        end
        
        % Updates the utilization time for a specified doctor
        function updateDoctorUtilization(obj, doctorId, timeSpent)
            obj.doctorUtilizations(doctorId) = obj.doctorUtilizations(doctorId) + timeSpent;
        end

        % Calculates key statistics from the data collected during the simulation
        function stats = calculateStatistics(obj, totalSimulationTime)
            obj.cleanUpQueueHistory();  % Ensure only unique, final entries for each time point
            
            averageWaitingTime = 0;
            if obj.totalPatients > 0
                averageWaitingTime = obj.totalWaitingTime / obj.totalPatients;
            end

            doctorUtilizationsStat = (obj.doctorUtilizations / totalSimulationTime) * 100;
            
            stats = struct(...
                'AverageWaitingTime', averageWaitingTime, ...
                'DoctorUtilizations', doctorUtilizationsStat, ...
                'QueueLengthHistory', obj.queueLengthHistory ...
            );
        end
        
        % Plots the history of the queue length as a staircase graph
        function plotQueueLength(obj)
            figure;
            stairs(obj.queueLengthHistory(:,1), obj.queueLengthHistory(:,2), 'LineWidth', 2);
            title('Queue Length Over Time');
            xlabel('Time (minutes)');
            ylabel('Number of Patients in Queue');
            grid on;
            
            if ~isempty(obj.queueLengthHistory)
                maxY = max(obj.queueLengthHistory(:,2));
                yticks(0:maxY);  % Only show whole number ticks
            end
        end

        % Plots the utilization of each doctor as a colored bar graph
       function plotDoctorUtilization(obj, totalSimulationTime)
            utilizationPercentages = (obj.doctorUtilizations / totalSimulationTime) * 100;
            figure;
        
            % Increase figure size for better layout
            set(gcf, 'Position', [100, 100, 800, 400]);  % [left, bottom, width, height]

            colors = zeros(length(utilizationPercentages), 3);  % Initialize color matrix
        
            % Define colors based on utilization percentages
            for i = 1:length(utilizationPercentages)
                if utilizationPercentages(i) >= 90
                    colors(i, :) = [1 0 0];  % Red for overutilized
                elseif utilizationPercentages(i) >= 70
                    colors(i, :) = [0 1 0];  % Green for optimal
                elseif utilizationPercentages(i) >= 50
                    colors(i, :) = [0 0.5 1];  % Light blue for underutilized
                else
                    colors(i, :) = [0.6 0.6 0.6];  % Gray for significantly underutilized
                end
            end
        
            % Create bar plot with flat colors
            b = bar(utilizationPercentages, 'FaceColor', 'flat');
            b.CData = colors;  % Apply the colors to the bars
            title('Doctor Utilization Rates');
            xlabel('Doctor ID');
            ylabel('Utilization (%)');
            xticks(1:length(obj.doctorUtilizations));
            grid on;

            % Adjusting y-axis limits to accommodate text and legend
            ylim([0 max(utilizationPercentages) * 1.2]);  % Adding 20% padding
        
            % Adding text labels above bars
            for i = 1:length(utilizationPercentages)
                text(b.XData(i), b.YData(i), sprintf('%.1f%%', b.YData(i)), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            end
        
            % Add a legend by plotting empty data with the same colors used for categories
            hold on;
            h = zeros(4, 1);
            h(1) = bar(NaN, 'FaceColor', [1 0 0]);  % Overutilized
            h(2) = bar(NaN, 'FaceColor', [0 1 0]);  % Optimal
            h(3) = bar(NaN, 'FaceColor', [0 0.5 1]);  % Underutilized
            h(4) = bar(NaN, 'FaceColor', [0.6 0.6 0.6]);  % Significantly Underutilized

            legend(h, {'Overutilized (>=90%)', 'Optimal (70-89%)', 'Underutilized (50-69%)', 'Significantly Underutilized (<50%)'}, ...
                'Location', 'northeastoutside');  % Positioning legend outside the northeast of the axes

            hold off;
        end


        % Cleans up the queue length history to ensure only the last entry per unique time is kept
        function cleanUpQueueHistory(obj)
            if isempty(obj.queueLengthHistory)
                return;
            end

            % Aggregate to the latest entry per unique timestamp
            uniqueTimes = unique(obj.queueLengthHistory(:,1));
            newQueueLengthHistory = zeros(length(uniqueTimes), 2);

            for i = 1:length(uniqueTimes)
                % Find all indices where this time occurs
                indices = find(obj.queueLengthHistory(:,1) == uniqueTimes(i));
                % Take the last index (which corresponds to the last record for this time)
                lastIdx = indices(end);
                % Save the time and the corresponding last queue length 
                newQueueLengthHistory(i,:) = obj.queueLengthHistory(lastIdx,:);
            end

            obj.queueLengthHistory = newQueueLengthHistory;
        end

        % Displays the calculated statistics and plots the graphs
        function displayStatistics(obj, totalSimulationTime)
            disp(['Average Waiting Time: ', num2str(obj.calculateStatistics(totalSimulationTime).AverageWaitingTime), ' minutes']);
            disp('Doctor Utilizations: ');
            utilizations = obj.calculateStatistics(totalSimulationTime).DoctorUtilizations;
            for i = 1:numel(utilizations)
                disp(['Doctor ', num2str(i), ': ', num2str(utilizations(i), '%.2f'), '%']);
            end
            obj.plotQueueLength();
            obj.plotDoctorUtilization(totalSimulationTime);
        end
    end
end
