import { LightningElement, api } from 'lwc';
import casa1 from '@salesforce/resourceUrl/Casa1';

export default class ImageDisplay extends LightningElement {
  @api imageUrl = casa1;  // Agrega @api para que sea accesible desde template y App Builder
  @api altText = 'Imagen decorativa casa1';
}
