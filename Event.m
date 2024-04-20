classdef Event
    % Event defines a specific occurrence within the clinic simulation.
    % This class handles different types of events like patient arrival,
    % start of treatment, and end of treatment.

    properties
        time;           % Time at which the event occurs
        type;           % Type of the event ('arrival', 'startTreatment', 'endTreatment')
        patient;        % The patient associated with the event, if applicable
        doctor;         % The doctor associated with the event, if applicable
    end

    methods
        function obj = Event(time, type, patient, doctor)
            % Constructor for creating a new Event.
            % Inputs:
            %   time    - The simulation time at which the event occurs
            %   type    - The type of event (e.g., 'arrival')
            %   patient - The patient involved in the event, if applicable
            %   doctor  - The doctor involved in the event, if applicable
            
            obj.time = time;
            obj.type = type;
            obj.patient = patient;
            obj.doctor = doctor;
        end       
    end

    methods(Static)
        % Static factory methods for creating specific types of events

        function event = createArrival(time, patient)
            % Creates an arrival event for a patient.
            % Inputs:
            %   time    - The simulation time at which the patient arrives
            %   patient - The patient who is arriving
            % Output:
            %   event   - The created arrival event

            event = Event(time, 'arrival', patient, []);
        end
        
        function event = createStartTreatment(time, patient, doctor)
            % Creates a start treatment event.
            % Inputs:
            %   time    - The simulation time at which treatment starts
            %   patient - The patient who is starting treatment
            %   doctor  - The doctor who will perform the treatment
            % Output:
            %   event   - The created start treatment event

            event = Event(time, 'startTreatment', patient, doctor);
        end
        
        function event = createEndTreatment(time, patient, doctor)
            % Creates an end treatment event.
            % Inputs:
            %   time    - The simulation time at which treatment ends
            %   patient - The patient whose treatment is ending
            %   doctor  - The doctor who performed the treatment
            % Output:
            %   event   - The created end treatment event

            event = Event(time, 'endTreatment', patient, doctor);
        end
    end
end
