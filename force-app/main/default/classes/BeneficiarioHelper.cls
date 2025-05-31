public class BeneficiarioHelper {

    // Variable estática para controlar recursividad (evita que se ejecute más de una vez en la misma transacción)
    private static Boolean isRunning = false;

    // Método para calcular la edad exacta a partir de la fecha de nacimiento
    public static Integer calculaEdad(Date fechaNacimiento){
        // Si la fecha es nula, devuelve 0 para evitar errores
        if(fechaNacimiento == null) return 0;

        // Obtiene la fecha actual
        Date hoy = Date.today();

        // Calcula la diferencia de años entre el año actual y el año de nacimiento
        Integer edad = hoy.year() - fechaNacimiento.year();

        // Ajusta la edad si el cumpleaños aún no ha ocurrido en el año actual
        if(hoy.month() < fechaNacimiento.month() || (hoy.month() == fechaNacimiento.month() && hoy.day() < fechaNacimiento.day())){
            edad--;
        }

        // Retorna la edad calculada
        return edad;
    }

    // Método para validar que no haya más de 2 beneficiarios mayores o iguales a 65 años por contacto
    public static void validaBeneficiarios(List<Beneficiario__c> beneficiarios){
        // Conjunto para almacenar los Ids de contactos relacionados con los beneficiarios en la lista
        Set<Id> contactosIds = new Set<Id>();

        // Recorre los beneficiarios para obtener los Ids de contactos no nulos
        for(Beneficiario__c b: beneficiarios){
            if(b.Contact__c != null){
                contactosIds.add(b.Contact__c);
            }
        }

        // Si no hay contactos, termina la validación
        if(contactosIds.isEmpty()) return;

        // Mapa para almacenar la cantidad de beneficiarios mayores de 65 ya existentes en la base de datos (excluyendo los que están en la lista actual)
        Map<Id, Integer> mayores65ExistentesPorContacto = new Map<Id, Integer>();

        // Consulta agregada para contar beneficiarios mayores o iguales a 65 años agrupados por contacto
        for(AggregateResult ar : [
            SELECT Contact__c c, COUNT(Id) total
            FROM Beneficiario__c
            WHERE Contact__c IN :contactosIds
              AND Edad__c >= 65
              AND Id NOT IN :beneficiarios
            GROUP BY Contact__c
        ]){
            // Almacena el conteo en el mapa usando el Id de contacto como clave
            mayores65ExistentesPorContacto.put((Id)ar.get('c'), (Integer)ar.get('total'));
        }

        // Mapa para contar beneficiarios mayores o iguales a 65 años que se están procesando en la lista actual por contacto
        Map<Id, Integer> mayores65NuevosPorContacto = new Map<Id, Integer>();

        // Recorre la lista de beneficiarios actual para calcular edades y actualizar el conteo de mayores de 65 por contacto
        for(Beneficiario__c b : beneficiarios){
            // Calcula la edad usando el método calculaEdad
            Integer edad = calculaEdad(b.Fecha_nacimiento__c);

            // Actualiza el campo Edad__c en memoria (antes de persistir)
            b.Edad__c = edad;

            // Si el beneficiario tiene contacto y es mayor o igual a 65, incrementa el conteo en el mapa
            if(b.Contact__c != null && edad >= 65){
                Integer actual = mayores65NuevosPorContacto.containsKey(b.Contact__c) ? mayores65NuevosPorContacto.get(b.Contact__c) : 0;
                mayores65NuevosPorContacto.put(b.Contact__c, actual + 1);
            }
        }

        // Valida que la suma de beneficiarios mayores existentes y nuevos no exceda el máximo permitido (2)
        for(Id contactoId : mayores65NuevosPorContacto.keySet()){
            // Obtiene la cantidad existente de beneficiarios mayores de 65 para el contacto
            Integer existentes = mayores65ExistentesPorContacto.containsKey(contactoId) ? mayores65ExistentesPorContacto.get(contactoId) : 0;

            // Obtiene la cantidad nueva de beneficiarios mayores de 65 para el contacto
            Integer nuevos = mayores65NuevosPorContacto.get(contactoId);

            // Si la suma excede 2, se marca error en todos los beneficiarios mayores de 65 del contacto
            if(existentes + nuevos > 2){
                for(Beneficiario__c b : beneficiarios){
                    Integer edad = calculaEdad(b.Fecha_nacimiento__c);
                    if(b.Contact__c == contactoId && edad >= 65){
                        // Agrega error para evitar guardar este beneficiario
                        b.addError('Ya tiene registrado el máximo de beneficiarios mayores de 65');
                    }
                }
            }
        }
    }

    // Método para actualizar conteos y generar llave externa única para cada beneficiario
    public static void actualizaConteosYLlaveExterna(List<Beneficiario__c> beneficiarios){
        // Evita ejecución recursiva
        if(isRunning) return;
        isRunning = true;

        // Obtiene los Ids de contactos de los beneficiarios procesados
        Set<Id> contactosIds = new Set<Id>();
        for(Beneficiario__c b: beneficiarios){
            if(b.Contact__c != null){
                contactosIds.add(b.Contact__c);
            }
        }

        // Si no hay contactos, libera flag y termina ejecución
        if(contactosIds.isEmpty()) {
            isRunning = false;
            return;
        }

        // Mapa para agrupar beneficiarios por contacto
        Map<Id, List<Beneficiario__c>> beneficiariosPorContacto = new Map<Id, List<Beneficiario__c>>();

        // Consulta todos los beneficiarios de los contactos involucrados, ordenados por fecha de creación
        for(Beneficiario__c b : [
            SELECT Id, Fecha_nacimiento__c, Contact__c, Llave_Externa__c
            FROM Beneficiario__c
            WHERE Contact__c IN :contactosIds
            ORDER BY CreatedDate ASC
        ]){
            // Si el contacto aún no está en el mapa, crea la lista
            if(!beneficiariosPorContacto.containsKey(b.Contact__c)){
                beneficiariosPorContacto.put(b.Contact__c, new List<Beneficiario__c>());
            }
            // Agrega el beneficiario a la lista del contacto correspondiente
            beneficiariosPorContacto.get(b.Contact__c).add(b);
        }

        // Consulta los contactos para actualizar sus campos de conteo
        Map<Id, Contact> mapContactos = new Map<Id, Contact>(
            [SELECT Id, Numero_de_identificacion__c, Total_de_beneficiarios__c, Cantidad_de_beneficiarios_mayor_de_65__c FROM Contact WHERE Id IN :contactosIds]
        );

        // Listas para almacenar beneficiarios y contactos que serán actualizados
        List<Beneficiario__c> beneficiariosToUpdate = new List<Beneficiario__c>();
        List<Contact> contactosToUpdate = new List<Contact>();

        // Recorre cada contacto para actualizar conteos y llaves externas
        for(Id contactoId : beneficiariosPorContacto.keySet()){
            // Obtiene la lista de beneficiarios del contacto
            List<Beneficiario__c> listaBen = beneficiariosPorContacto.get(contactoId);

            // Calcula el total de beneficiarios y prepara contador para mayores de 65 y consecutivo
            Integer totalBeneficiarios = listaBen.size();
            Integer mayores65 = 0;
            Integer consecutivo = 1;

            // Obtiene el contacto desde el mapa de contactos consultados
            Contact contacto = mapContactos.get(contactoId);
            // Si el contacto no existe (caso raro), continúa con el siguiente
            if(contacto == null) continue;

            // Recorre beneficiarios para calcular edad, actualizar contador y asignar llave externa
            for(Beneficiario__c ben : listaBen){
                // Calcula y actualiza edad
                Integer edad = calculaEdad(ben.Fecha_nacimiento__c);
                ben.Edad__c = edad;

                // Cuenta si es mayor o igual a 65
                if(edad >= 65) mayores65++;

                // Construye llave externa con número de identificación del contacto + consecutivo
                String numeroId = contacto.Numero_de_identificacion__c != null ? contacto.Numero_de_identificacion__c : 'NA';
                ben.Llave_Externa__c = numeroId + '-' + consecutivo;
                consecutivo++;

                // Añade beneficiario a la lista para actualizar
                beneficiariosToUpdate.add(ben);
            }

            // Actualiza campos de conteo en el contacto
            contacto.Total_de_beneficiarios__c = totalBeneficiarios;
            contacto.Cantidad_de_beneficiarios_mayor_de_65__c = mayores65;

            // Añade contacto a la lista para actualizar
            contactosToUpdate.add(contacto);
        }

        // Actualiza beneficiarios en base de datos si hay alguno que actualizar
        if(!beneficiariosToUpdate.isEmpty()){
            update beneficiariosToUpdate;
        }
        // Actualiza contactos en base de datos si hay alguno que actualizar
        if(!contactosToUpdate.isEmpty()){
            update contactosToUpdate;
        }

        // Libera flag para permitir futuras ejecuciones
        isRunning = false;
    }
}
