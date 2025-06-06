# Salesforce Beneficiarios Validation

Este proyecto contiene una lógica en **Apex** para validar y contar los beneficiarios mayores o iguales a 65 años para los contactos en Salesforce. Utiliza un trigger y una clase auxiliar para realizar la validación y actualización de los datos.

## Descripción

La clase `BeneficiarioHelper` valida que un contacto no tenga más de 2 beneficiarios mayores de 65 años y actualiza el campo `Llave_Externa__c` con un identificador único para cada beneficiario. Además, la clase calcula la edad de cada beneficiario y actualiza el campo `Edad__c` de manera automática.

## Características

- **Cálculo de Edad**: La clase `BeneficiarioHelper` calcula la edad de los beneficiarios con base en la fecha de nacimiento.
- **Validación de Beneficiarios**: Asegura que un contacto no tenga más de 2 beneficiarios mayores de 65 años.
- **Actualización de Llave Externa**: Genera un identificador único para cada beneficiario.
- **Uso de Trigger**: El trigger `BeneficiarioTrigger` invoca la lógica de la clase `BeneficiarioHelper` para validar y actualizar los beneficiarios en eventos de `insert`, `update` y `delete`.

## Tecnología

- **Salesforce Apex**
- **Triggers**
- **SOQL** (Salesforce Object Query Language)


