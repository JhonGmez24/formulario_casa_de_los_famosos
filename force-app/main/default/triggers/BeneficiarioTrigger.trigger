trigger BeneficiarioTrigger on beneficiario__c (before insert, before delete, before update, after insert, after update, after delete){

    if (trigger.isBefore) {
        if (Trigger.isInsert || trigger.isUpdate){

        BeneficiarioHelper.validaBeneficiarios(Trigger.new);
     }
    else if 
        (Trigger.isDelete){
        BeneficiarioHelper.validaBeneficiarios(Trigger.old);
    
     }


    }

    if (Trigger.isAfter){If (Trigger.IsUpdate)
    {
        BeneficiarioHelper.actualizaConteosYLlaveExterna(Trigger.New);

    }
    
    else if(Trigger.isDelete){
        BeneficiarioHelper.actualizaConteosYLlaveExterna(Trigger.Old);
    }
    }

}