public with sharing class VotacionController {
    
    // Método para obtener los candidatos (este método debe ser estático y con @AuraEnabled)
    @AuraEnabled(cacheable=true)
    public static List<Candidato__c> obtenerCandidatos() {
        // Recupera los candidatos con su nombre y URL de la imagen
        return [SELECT Id, Nombre_del_Candidato__c, URL_de_la_Imagen__c FROM Candidato__c];
    }

    // Método para guardar la votación (también debe ser estático y con @AuraEnabled)
    @AuraEnabled
    public static void registrarVotacion(String nombre, String identificacion, Id candidatoId) {
        // Verifica si ya existe una votación con el mismo nombre e identificación
        List<Votacion__c> votosExistentes = [SELECT Id FROM Votacion__c WHERE Nombre_del_votante__c = :nombre AND Identificacion_del_votante__c = :identificacion LIMIT 1];
        if (!votosExistentes.isEmpty()) {
            throw new AuraHandledException('Ya existe una votación registrada con este nombre e identificación.');
        }

        // Si no existe, crea un nuevo registro de votación
        Votacion__c nuevaVotacion = new Votacion__c(
            Nombre_del_votante__c = nombre, 
            Identificacion_del_votante__c = identificacion, 
            Candidato_Votado__c = candidatoId
        );
        insert nuevaVotacion;
    }
}
