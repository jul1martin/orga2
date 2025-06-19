#include "ej1.h"

char** agrupar_c(msg_t* msgArr, size_t msgArr_len){
     char** arr = malloc(8 * MAX_TAGS);

     for (size_t i = 0; i < MAX_TAGS; i++) {
          arr[i] = (char*) malloc(8);

          if (arr[i] != NULL) {
               arr[i][0] = '\0';        // Marca el string como vacío
          }
     }

     for (size_t i = 0; i < msgArr_len; i++) {
          msg_t data = msgArr[i];
          
          // printf("hola %i",data.tag);
          
          for (size_t j = 0; j < data.text_len; j++)
          {
               arr[data.tag][j] = arr[data.tag][j];
          }
          
     }

     return arr;
}
