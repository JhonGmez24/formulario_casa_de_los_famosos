trigger BeneficiarioTrigger on Beneficiario__c (
    before insert,
    before update,
    after insert,
    after update,
    after delete
) {
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            BeneficiarioHelper.validaBeneficiarios(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            BeneficiarioHelper.actualizaConteosYLlaveExterna(Trigger.new);
        } else if(Trigger.isDelete){
            BeneficiarioHelper.actualizaConteosYLlaveExterna(Trigger.old);
        }
    }
}
