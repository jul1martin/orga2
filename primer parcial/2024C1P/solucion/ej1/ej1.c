#include "ej1.h"

nodo_display_list_t* inicializar_nodo(
  uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size),
  uint8_t x, uint8_t y, nodo_display_list_t* siguiente) {
    nodo_display_list_t* nodo = malloc(sizeof(nodo_display_list_t));
    nodo->primitiva = primitiva;
    nodo->x = x;
    nodo->y = y;
    nodo->z = 255;
    nodo->siguiente = siguiente;
    return nodo;
}

ordering_table_t* inicializar_OT(uint8_t table_size) {
  ordering_table_t* ot = malloc(sizeof(ordering_table_t));

  ot->table_size = table_size;
  ot->table = malloc(sizeof(nodo_ot_t*) * table_size);

  for (size_t i = 0; i < table_size; i++) {
    ot->table[i] = NULL;
  }
  
  return ot;
}

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size) {
  nodo->z = ((nodo->primitiva)(nodo->x, nodo->y, z_size));
}

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) {
  calcular_z(display_list, ot->table_size);

  nodo_ot_t* node = ot->table[display_list->z];

  while(node != NULL) {
    nodo_ot_t* oldNode = node;

    node = node->siguiente;

    if(node == NULL) {
      oldNode->siguiente = node;
    }
  }

  nodo_ot_t* newNode =  
  node->display_element = display_list;
  node->siguiente = NULL;

  return;
}
