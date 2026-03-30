trigger ServiceContractTrigger on ServiceContract (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ServiceContractTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
