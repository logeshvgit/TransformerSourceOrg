trigger CaseTrigger on Case (after insert, after update) {
    if (Trigger.isAfter) {
        CaseAccountMetricsService.handleCaseAfter(Trigger.new, Trigger.oldMap);
    }
}
