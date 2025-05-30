public class BeneficiarioHelper {

    public static void validaBeneficiarios(List<Beneficiario__c> beneficiarios){


        



Set<Id> contactosIds = new  set<Id>();
for(beneficiario__c b: beneficiarios){

    if (b.Contact__C != null){

    contactosIds.add(b.Contact__C);
}

 
}

if(Contactosids.isEmpty()) return;
Map < Id , List <Beneficiario__c>> beneficiariosPorContacto = new Map<Id, List<Beneficiario__c>>();
for (Beneficiario__c b: [

    SELECT ID, Fecha_nacimiento__c , Contact__C
    FROM Beneficiario__c
    WHERE contact__c IN: Contactosids
])

{
if (!beneficiariosPorContacto.containsKey(b.Contact__C)) {

    beneficiariosPorContacto.put(b.Contact__c, new List<Beneficiario__c>());}

    beneficiariosPorContacto.get(b.Contact__c).add(b);}

    for (Beneficiario__c bNew : beneficiarios){

if (bNew.contact__c==null) continue;

Integer edad = calculaEdad(bNew.Fecha_nacimiento__c);
Integer mayores65Existentes = 0;

List<Beneficiario__c> lista = beneficiariosPorContacto.get(bNew.Contact__C);


if (lista != null){

    for (Beneficiario__c bExist: lista)
    {
        if (bExist.Id == bNew.Id) continue;
        if(calculaEdad(bExist.Fecha_nacimiento__c)>= 65)
        {
            mayores65Existentes ++;
        }
    }
}
if (edad >= 65 && mayores65Existentes >= 2){
bNew.addError('El beneficiario no puede ser de mas de edad y ser una persona mayor (65+)');}
    }
    }

    public static Integer calculaEdad(Date fechaNacimiento){
        if (fechaNacimiento == null) return 0;
        Integer edad = Date.today().year() - fechaNacimiento.year();
        if(fechaNacimiento.month()>Date.today().month() || (fechaNacimiento.month() == Date.today().month() && fechaNacimiento.day()>Date.today().day()))
        {edad--;}
        return edad;
    }

    public static void actualizaConteosYLlaveExterna(List<Beneficiario__c> beneficiarios){
        Set<Id> contactosIds = new Set <Id> ();
        for(Beneficiario__c b: beneficiarios){
            if (b.Contact__C != null){

                contactosIds.add(b.Contact__C);
            }
        }
        if (contactosIds.isEmpty()) return;
        Map<Id,List<Beneficiario__c>> beneficiariosPorContacto = new Map<Id,List<Beneficiario__c>>();
        for (Beneficiario__c b:[
            select Id,Fecha_nacimiento__c,contact__c,Llave_externa__c
            from Beneficiario__c
            where contact__c IN:ContactosIds
            order by CreatedDate ASC




        ])

        {
if (!beneficiariosPorContacto.containsKey(b.Contact__C)) {

    beneficiariosPorContacto.put(b.Contact__c, new List<Beneficiario__c>());}

    beneficiariosPorContacto.get(b.Contact__c).add(b);}

    List<Beneficiario__c>beneficiariosToUpdtate = new List<Beneficiario__c>();
    
    List<Contact> contacsToUpdate = new List<Contact>();

    Map<Id, Contact> mapContactos = new Map<Id,Contact>(

    [select Id,Numero_de_identificacion__c,Total_de_beneficiarios__c,Cantidad_de_beneficiarios_mayor_de_65__c from Contact where Id in :ContactosIds] );

    for (Id contactoId : beneficiariosPorContacto.KeySet()){
        
        List<Beneficiario__c> listaBen = beneficiariosPorContacto.get(contactoId);

        Integer totalBeneficiarios = listaBen.size();
        Integer mayores65 = 0;
        Integer consecutivo=1;

        Contact contacto=mapContactos.get(contactoId);
        if (contacto == null) continue;


        for (Beneficiario__c ben : listaBen){

            Integer edad=calculaEdad(ben.Fecha_nacimiento__c);
            if (edad >= 65) mayores65++;

            ben.Llave_externa__c = contacto.Numero_de_identificacion__c + '-' + String.valueOf(consecutivo);
            consecutivo++;
            beneficiariosToUpdtate.add(ben);
        }
        contacto.Total_de_beneficiarios__c= totalBeneficiarios;
        contacto.Cantidad_de_beneficiarios_mayor_de_65__c = mayores65;
        contacsToUpdate.add(contacto);
    } 

    if (!beneficiariosToUpdtate.isEmpty())
        update beneficiariosToUpdtate;
    
    if (!contacsToUpdate.isEmpty())
        update contacsToUpdate;
}
}