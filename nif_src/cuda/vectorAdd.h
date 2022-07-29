#ifndef VECTOR_ADD_H
#define VECTOR_ADD_H

#include <stdbool.h>
#include <stdint.h>

#define MAXBUFLEN 1024

#ifdef __cplusplus
extern "C" {
#endif
bool add_s32_cuda(const int32_t *x, const int32_t *y, int32_t *z, uint64_t numElements, char *error);
#ifdef __cplusplus
}
#endif

#endif // VECTOR_ADD_H
