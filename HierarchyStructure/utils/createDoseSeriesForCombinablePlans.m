function [series, pixelData] = createDoseSeriesForCombinablePlans(patient, planUids)
%CREATECOMBINEDDOSE add a combined dicom set to patient
%
% [series, pixelData] = createDoseSeriesForCombinablePlans(patient, planUids)
%
% See also: PATIENT, SERIES, COMBINEDOSEPIXELDATA, CREATELISTOFCOMBINABLEPLANS
    series = Series();
    pixelData = [];
    
    nrOfPlans = length(planUids);
    if nrOfPlans == 1
        warning('only one plan provided, nothing to do here!');
        return;
    end
    
    dose = RtDose();
    for i = 1:nrOfPlans
        dose(i) = getRtDoseForPlan(patient, planUids{i});
    end
    [pixelData, doseGridScaling] = combineDosePixelData(dose);

    
    newSeriesUid = dicomuid;
    newSeriesDescription = 'Combined plan RTDOSE collection';
    for i = 1:length(dose)
        newDose = newDoseHeader(dose(i), newSeriesUid, newSeriesDescription, doseGridScaling);
        series = series.parseDicomObj(newDose);
    end
end

function dose = newDoseHeader(dose, newSeriesUid, newSeriesDescription, doseGridScaling)
    dose.dicomHeader.SOPInstanceUID = dicomuid;
    dose.dicomHeader.SeriesInstanceUid = newSeriesUid;
    dose.dicomHeader.SeriesDescription = newSeriesDescription;
    dose.dicomHeader.ManufacturerModelName = 'PlanDoseCombiner';
    dose.dicomHeader.Manufacturer = 'MAASTRO SDT';
    dose.dicomHeader.DoseGridScaling = doseGridScaling;
end