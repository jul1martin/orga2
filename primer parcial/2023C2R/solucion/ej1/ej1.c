#include "ej1.h"

string_proc_list* string_proc_list_create(void){
	string_proc_list* nuevo = malloc(16);
	nuevo->first = NULL;
	nuevo->last = NULL;
	return nuevo;
}

string_proc_node* string_proc_node_create(uint8_t type, char* hash){
	string_proc_node* nuevo = malloc(32);
	nuevo->type = type;
	nuevo->hash = hash;
	nuevo->next = NULL;
	nuevo->previous = NULL;
	return nuevo;
}

void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash){
	string_proc_node* nuevo = string_proc_node_create(type,hash);
	
	if (list->last != NULL)
	{
		list->last->next = nuevo;
		nuevo->previous = list->last;
	}

	list->last = nuevo;

		
	if (list->first == NULL) list->first = nuevo;
}

char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
	string_proc_node* actual = list->first;
	
	char* resultado = malloc(strlen(hash)+1);
	strcpy(resultado,hash);
	
	while( actual != NULL) {
		if (actual->type == type) {
			char* nuevo_resultado = (char*)str_concat(resultado,actual->hash);
			free(resultado);
			resultado = nuevo_resultado;
		}
		actual = actual->next;
	}
	return resultado;
}


/** AUX FUNCTIONS **/

void string_proc_list_destroy(string_proc_list* list){

	/* borro los nodos: */
	string_proc_node* current_node	= list->first;
	string_proc_node* next_node		= NULL;
	while(current_node != NULL){
		next_node = current_node->next;
		string_proc_node_destroy(current_node);
		current_node	= next_node;
	}
	/*borro la lista:*/
	list->first = NULL;
	list->last  = NULL;
	free(list);
}
void string_proc_node_destroy(string_proc_node* node){
	node->next      = NULL;
	node->previous	= NULL;
	node->hash		= NULL;
	node->type      = 0;			
	free(node);
}


char* str_concat(char* a, char* b) {
	int len1 = strlen(a);
    int len2 = strlen(b);
	int totalLength = len1 + len2;
    char *result = (char *)malloc(totalLength + 1); 
    strcpy(result, a);
    strcat(result, b);
    return result;  
}

void string_proc_list_print(string_proc_list* list, FILE* file){
        uint32_t length = 0;
        string_proc_node* current_node  = list->first;
        while(current_node != NULL){
                length++;
                current_node = current_node->next;
        }
        fprintf( file, "List length: %d\n", length );
		current_node    = list->first;
        while(current_node != NULL){
                fprintf(file, "\tnode hash: %s | type: %d\n", current_node->hash, current_node->type);
                current_node = current_node->next;
        }
}