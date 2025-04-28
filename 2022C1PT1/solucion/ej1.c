#include "ejs.h"
#include "str.h"

// str_array_t* strArrayNew(uint8_t capacity) {
//     str_array_t* newArray = malloc(16);

//     newArray->size = 0;
//     newArray->capacity = capacity;
//     newArray->data = malloc(sizeof(char*) * capacity);

//     return newArray;
// }

// uint8_t strArrayGetSize(str_array_t* a) {
//     return a->size;
// }

// 0x407480
// data 0x00007ffff7600010
// void strArrayAddLast(str_array_t* a, char* data) {
//     uint8_t aSize = strArrayGetSize(a);

//     if(aSize == a->capacity) return;

//     a->size++;
    
//     char* copy_char = strClone(data);

//     a->data[aSize] = copy_char;
// }

// void strArraySwap(str_array_t* a, uint8_t i, uint8_t j) {
//     // uint8_t aSize = strArrayGetSize(a);

//     // if(aSize <= i || aSize <= j) return;

//     char* toSwitch = a->data[i];
//     char* toSwitch2 = a->data[j];

//     a->data[i] = toSwitch2;
//     a->data[j] = toSwitch;
// }

// void strArrayDelete(str_array_t* a) {
//     for (size_t i = 0; i < a->size; i++)
//     {
//         free(a->data[i]);
//     }
    
//     free(a->data);
//     free(a);
// }

void strArrayPrint(str_array_t* a, FILE* pFile) {
    fprintf(pFile, "[");
    for(int i=0; i<a->size-1; i++) {
        strPrint(a->data[i], pFile);
        fprintf(pFile, ",");
    }
    if(a->size >= 1) {
        strPrint(a->data[a->size-1], pFile);
    }
    fprintf(pFile, "]");
}

char* strArrayRemove(str_array_t* a, uint8_t i) {
    char* ret = 0;
    if(a->size > i) {
        ret = a->data[i];
        for(int k=i+1;k<a->size;k++) {
            a->data[k-1] = a->data[k];
        }
        a->size = a->size - 1;
    }
    return ret;
}

char* strArrayGet(str_array_t* a, uint8_t i) {
    char* ret = 0;
    if(a->size > i)
        ret = a->data[i];
    return ret;
}
