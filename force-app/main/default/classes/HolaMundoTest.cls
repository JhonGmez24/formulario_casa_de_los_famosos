@isTest
private class HolaMundoTest {
    @isTest static void testDecirHola() {
        String saludo = holaMundo.decirHola();
        System.assertEquals('¡Hola Salesforce Apex!', saludo);
    }
}
