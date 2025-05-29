import { LightningElement, track } from 'lwc';
import obtenerCandidatos from '@salesforce/apex/VotacionController.obtenerCandidatos';
import registrarVotacion from '@salesforce/apex/VotacionController.registrarVotacion';

export default class VotacionForm extends LightningElement {
    @track nombre = '';
    @track identificacion = '';
    @track candidatoId = '';
    @track candidatos = [];
    @track candidatoImagen = '';
    @track candidatoNombre = '';
    @track errorMessage = '';

    // Obtener los candidatos desde Apex
    connectedCallback() {
        obtenerCandidatos()
            .then(result => {
                this.candidatos = result.map(candidato => ({
                    label: candidato.Nombre_del_Candidato__c,
                    value: candidato.Id
                }));
            })
            .catch(error => {
                this.errorMessage = 'Error al cargar los candidatos.';
                console.error(error);
            });
    }

    // Maneja el cambio de valor del nombre
    handleNombreChange(event) {
        this.nombre = event.target.value;
    }

    // Maneja el cambio de valor de la identificación
    handleIdentificacionChange(event) {
        this.identificacion = event.target.value;
    }

    // Maneja el cambio de valor del candidato
    handleCandidatoChange(event) {
        this.candidatoId = event.target.value;
        // Obtener la URL de la imagen y el nombre del candidato seleccionado
        const candidatoSeleccionado = this.candidatos.find(candidato => candidato.value === this.candidatoId);
        if (candidatoSeleccionado) {
            this.candidatoNombre = candidatoSeleccionado.label;
            this.candidatoImagen = candidatoSeleccionado.URL_de_la_Imagen__c;
        }
    }

    // Maneja el clic del botón Votar
    handleVotar() {
        if (!this.nombre || !this.identificacion || !this.candidatoId) {
            this.errorMessage = 'Por favor, complete todos los campos.';
            return;
        }
    
        registrarVotacion({ nombre: this.nombre, identificacion: this.identificacion, candidatoId: this.candidatoId })
            .then(() => {
                this.errorMessage = '';
                this.nombre = '';
                this.identificacion = '';
                this.candidatoId = '';
                this.candidatoImagen = '';
                this.candidatoNombre = '';
                alert('Votación registrada correctamente.');
            })
            .catch(error => {
                if (error && error.body && error.body.message) {
                    this.errorMessage = error.body.message;
                } else {
                    this.errorMessage = 'Error al registrar la votación.';
                }
                console.error('Error al registrar la votación:', error);
            });
    }
}
