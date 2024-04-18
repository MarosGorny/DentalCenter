classdef Event
    properties
        time;           % Time the event occurs
        type;           % Type of event ('arrival', 'startTreatment', 'endTreatment')
        patient;        % Associated patient (if any)
        doctor;         % Associated doctor (if any)
    end
    methods
        function obj = Event(time, type, patient, doctor)
            obj.time = time;
            obj.type = type;
            obj.patient = patient;
            obj.doctor = doctor;
        end       
    end

    methods(Static)
        % Static methods to create specific types of events
        function event = createArrival(time, patient)
            event = Event(time, 'arrival', patient, []);
        end
        
        function event = createStartTreatment(time, patient, doctor)
            event = Event(time, 'startTreatment', patient, doctor);
        end
        
        function event = createEndTreatment(time, patient, doctor)
            event = Event(time, 'endTreatment', patient, doctor);
        end
    end
end
