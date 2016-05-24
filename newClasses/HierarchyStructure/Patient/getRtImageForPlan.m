function rtimage = getRtImageForPlan(patient, planUid)
if ~patient.rtimageForPlan.isKey(planUid)
    rtimage = [];
    return;
end
list = patient.rtimageForPlan(planUid);
rtimage = RtImage();
for i = 1:length(list)
    rtimage(i) = patient.getDicomModalityObject(list(i).sopInstanceUid);
end
end