classdef StatisticsManager < handle
    properties
        queueLengthHistory = []; % Store [time, queueLength] pairs
        totalWaitingTime = 0;
        totalPatients = 0;
        doctorUtilizations; % Array to store total working time for each doctor
    end
    
    methods (Access =public)
        function obj = StatisticsManager(numDoctors)
            obj.doctorUtilizations = zeros(numDoctors, 1);
        end
        
        function logQueueLength(obj, currentTime, queueLength)
            obj.queueLengthHistory = [obj.queueLengthHistory; [currentTime, queueLength]];
        end
        
        function logWaitingTime(obj, waitingTime)
            obj.totalWaitingTime = obj.totalWaitingTime + waitingTime;
            obj.totalPatients = obj.totalPatients + 1;
        end
        
        function updateDoctorUtilization(obj, doctorId, timeSpent)
            obj.doctorUtilizations(doctorId) = obj.doctorUtilizations(doctorId) + timeSpent;
        end

        % Calculate statistics and return them
        function stats = calculateStatistics(obj, totalSimulationTime)
            obj.cleanUpQueueHistory();
            
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
        
        function plotQueueLength(obj)
            figure;
            stairs(obj.queueLengthHistory(:,1), obj.queueLengthHistory(:,2), 'LineWidth', 2);
            title('Queue Length Over Time');
            xlabel('Time (minutes)');
            ylabel('Number of Patients in Queue');
            grid on;
            
            % Determine the range of queue lengths to set y-axis ticks appropriately
            if ~isempty(obj.queueLengthHistory)
                maxY = max(obj.queueLengthHistory(:,2));
                yticks(0:maxY); % Set y-ticks to only include integers up to the maximum queue length
            end            
        end

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

        function cleanUpQueueHistory(obj)
            if isempty(obj.queueLengthHistory)
                return;  % No data to clean up
            end
        
            % Initialize variables
            uniqueTimes = unique(obj.queueLengthHistory(:,1));
            newQueueLengthHistory = zeros(length(uniqueTimes), 2);
        
            % Loop through each unique time
            for i = 1:length(uniqueTimes)
                time = uniqueTimes(i);
                % Find all indices where this time occurs
                indices = find(obj.queueLengthHistory(:,1) == time);
                % Take the last index (which corresponds to the last record for this time)
                lastIdx = indices(end);
                % Save the time and the corresponding last queue length
                newQueueLengthHistory(i,:) = obj.queueLengthHistory(lastIdx,:);
            end
        
            % Replace the old history with the cleaned up version
            obj.queueLengthHistory = newQueueLengthHistory;
        end


        function displayStatistics(obj, totalSimulationTime)
            % Clean up the queue history to ensure accuracy
            obj.cleanUpQueueHistory();

            if obj.totalPatients > 0
                averageWaitingTime = obj.totalWaitingTime / obj.totalPatients;
                disp(['Average Waiting Time: ', num2str(averageWaitingTime), ' minutes']);
            end
            
            for i = 1:length(obj.doctorUtilizations)
                utilization = (obj.doctorUtilizations(i) / totalSimulationTime) * 100;
                disp(['Doctor ', num2str(i), ' Utilization: ', num2str(utilization), '%']);
            end
            
            obj.plotQueueLength();
            obj.plotDoctorUtilization(totalSimulationTime);
        end
    end
end
