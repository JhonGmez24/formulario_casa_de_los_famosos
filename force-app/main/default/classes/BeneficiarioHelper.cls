public class BeneficiarioHelper {

    // Variable estática para controlar recursividad (declarada directamente)
    private static Boolean isRunning = false;

    public static Integer calculaEdad(Date fechaNacimiento){
        if(fechaNacimiento == null) return 0;
        Date hoy = Date.today();
        Integer edad = hoy.year() - fechaNacimiento.year();
        if(hoy.month() < fechaNacimiento.month() || (hoy.month() == fechaNacimiento.month() && hoy.day() < fechaNacimiento.day())){
            edad--;
        }
        return edad;
    }

    public static void validaBeneficiarios(List<Beneficiario__c> beneficiarios){
        Set<Id> contactosIds = new Set<Id>();
        for(Beneficiario__c b: beneficiarios){
            if(b.Contact__c != null){
                contactosIds.add(b.Contact__c);
            }
        }
        if(contactosIds.isEmpty()) return;

        Map<Id, Integer> mayores65ExistentesPorContacto = new Map<Id, Integer>();
        for(AggregateResult ar : [
            SELECT Contact__c c, COUNT(Id) total
            FROM Beneficiario__c
            WHERE Contact__c IN :contactosIds
              AND Edad__c >= 65
              AND Id NOT IN :beneficiarios
            GROUP BY Contact__c
        ]){
            mayores65ExistentesPorContacto.put((Id)ar.get('c'), (Integer)ar.get('total'));
        }

        Map<Id, Integer> mayores65NuevosPorContacto = new Map<Id, Integer>();
        for(Beneficiario__c b : beneficiarios){
            Integer edad = calculaEdad(b.Fecha_nacimiento__c);
            b.Edad__c = edad; // Actualiza Edad__c en memoria
            if(b.Contact__c != null && edad >= 65){
                Integer actual = mayores65NuevosPorContacto.containsKey(b.Contact__c) ? mayores65NuevosPorContacto.get(b.Contact__c) : 0;
                mayores65NuevosPorContacto.put(b.Contact__c, actual + 1);
            }
        }

        for(Id contactoId : mayores65NuevosPorContacto.keySet()){
            Integer existentes = mayores65ExistentesPorContacto.containsKey(contactoId) ? mayores65ExistentesPorContacto.get(contactoId) : 0;
            Integer nuevos = mayores65NuevosPorContacto.get(contactoId);
            if(existentes + nuevos > 2){
                for(Beneficiario__c b : beneficiarios){
                    Integer edad = calculaEdad(b.Fecha_nacimiento__c);
                    if(b.Contact__c == contactoId && edad >= 65){
                        b.addError('Ya tiene registrado el máximo de beneficiarios mayores de 65');
                    }
                }
            }
        }
    }

    public static void actualizaConteosYLlaveExterna(List<Beneficiario__c> beneficiarios){
        if(isRunning) return;
        isRunning = true;

        Set<Id> contactosIds = new Set<Id>();
        for(Beneficiario__c b: beneficiarios){
            if(b.Contact__c != null){
                contactosIds.add(b.Contact__c);
            }
        }
        if(contactosIds.isEmpty()) {
            isRunning = false;
            return;
        }

        Map<Id, List<Beneficiario__c>> beneficiariosPorContacto = new Map<Id, List<Beneficiario__c>>();
        for(Beneficiario__c b : [
            SELECT Id, Fecha_nacimiento__c, Contact__c, Llave_Externa__c
            FROM Beneficiario__c
            WHERE Contact__c IN :contactosIds
            ORDER BY CreatedDate ASC
        ]){
            if(!beneficiariosPorContacto.containsKey(b.Contact__c)){
                beneficiariosPorContacto.put(b.Contact__c, new List<Beneficiario__c>());
            }
            beneficiariosPorContacto.get(b.Contact__c).add(b);
        }

        Map<Id, Contact> mapContactos = new Map<Id, Contact>(
            [SELECT Id, Numero_de_identificacion__c, Total_de_beneficiarios__c, Cantidad_de_beneficiarios_mayor_de_65__c FROM Contact WHERE Id IN :contactosIds]
        );

        List<Beneficiario__c> beneficiariosToUpdate = new List<Beneficiario__c>();
        List<Contact> contactosToUpdate = new List<Contact>();

        for(Id contactoId : beneficiariosPorContacto.keySet()){
            List<Beneficiario__c> listaBen = beneficiariosPorContacto.get(contactoId);
            Integer totalBeneficiarios = listaBen.size();
            Integer mayores65 = 0;
            Integer consecutivo = 1;

            Contact contacto = mapContactos.get(contactoId);
            if(contacto == null) continue;

            for(Beneficiario__c ben : listaBen){
                Integer edad = calculaEdad(ben.Fecha_nacimiento__c);
                ben.Edad__c = edad;
                if(edad >= 65) mayores65++;

                String numeroId = contacto.Numero_de_identificacion__c != null ? contacto.Numero_de_identificacion__c : 'NA';
                ben.Llave_Externa__c = numeroId + '-' + consecutivo;
                consecutivo++;

                beneficiariosToUpdate.add(ben);
            }

            contacto.Total_de_beneficiarios__c = totalBeneficiarios;
            contacto.Cantidad_de_beneficiarios_mayor_de_65__c = mayores65;
            contactosToUpdate.add(contacto);
        }

        if(!beneficiariosToUpdate.isEmpty()){
            update beneficiariosToUpdate;
        }
        if(!contactosToUpdate.isEmpty()){
            update contactosToUpdate;
        }

        isRunning = false;
    }
}
