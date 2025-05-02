#include "ej1.h"

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos) {
     uint32_t* pagosporcliente = malloc(sizeof(uint32_t) * 10);

     for(uint8_t i = 0; i < 10; i++) {
          pagosporcliente[i] = 0;
     }

     for (size_t i = 0; i < cantidadDePagos; i++)
     {
          pago_t pago = arr_pagos[i];

          if(((uint8_t) pago.aprobado) != 0) {
               pagosporcliente[pago.cliente] += (uint8_t) pago.monto;
          }
     }

     return pagosporcliente;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
     for (size_t i = 0; i < n; i++) {
          char* ncomercio = lista_comercios[i];

          if(strcmp(comercio, ncomercio) == 0) return 1;
     }
     
     return 0;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
     uint8_t index_pagos = 0; 
     pago_t** pagos = NULL;
     
     for (uint8_t i = 0; i < cantidad_pagos; i++) {
          pago_t pago = arr_pagos[i];

          if(en_blacklist(pago.comercio, arr_comercios, size_comercios)) {
               pagos = realloc(pagos, sizeof(pago_t*) * (index_pagos + 1));
               
               pagos[index_pagos] = (pago_t*) &arr_pagos[i];

               index_pagos++;
          }
     }
     
     return pagos;
}


