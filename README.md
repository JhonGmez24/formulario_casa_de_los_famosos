# Proyecto Formulario de Votación - Casa de los Famosos

## Descripción

Este proyecto consiste en una aplicación de votación desarrollada sobre la plataforma Salesforce. Permite a los usuarios registrarse con su nombre e identificación, y votar por su candidato preferido entre una lista de candidatos disponibles. Cada usuario puede votar una sola vez, y el sistema valida la duplicidad de votos.

La interfaz de usuario se desarrolló con **Lightning Web Components (LWC)** para una experiencia moderna y reactiva, y la lógica de backend se implementó con clases **Apex** que gestionan la obtención de candidatos y el registro de votaciones.

---PRUEBA JODAAAAAAAAAA!!

## Tecnologías utilizadas

- **Salesforce Platform**
- **Lightning Web Components (LWC)**
- **Apex (lenguaje de programación de Salesforce)**
- **Git y GitHub para control de versiones**
- **VS Code con Salesforce Extensions**

---

## Estructura del Proyecto

- `force-app/main/default/lwc/votacionForm/`: Componente LWC principal que contiene la UI y la lógica de votación.
- `force-app/main/default/classes/VotacionController.cls`: Clase Apex con métodos para obtener candidatos y registrar votos.
- `force-app/main/default/classes/VotacionController.cls-meta.xml`: Metadatos de la clase Apex.
- Otros archivos generados por Salesforce para despliegue y configuración.

---

## Funcionalidades principales

- Registro de usuario para votar (nombre e identificación).
- Visualización dinámica de la lista de candidatos con sus imágenes.
- Validación para que un usuario solo pueda votar una vez (por nombre e identificación).
- Alerta y mensaje de error en caso de intento de votación duplicada.
- Manejo de errores en frontend para informar al usuario.
- Integración entre LWC y Apex con métodos `@AuraEnabled`.

---

## Cómo usar este proyecto

1. Desplegar el código a tu organización Salesforce usando SFDX:
   ```bash
   sfdx force:source:push
