import numpy as np
cimport numpy as np
import random
import matplotlib.pyplot as plt
import cython
from libc.stdlib cimport rand, srand
from libc.math cimport sqrt, pow
from libc.time cimport time
srand(time(NULL))
# C function to sum all the elements.
cdef int arr_sum(int[::1] arr):
    cdef int i, total = 0
    cdef size_t n = len(arr)
    for i in range(n):
        total += arr[i]
    return total
# C function to simulate pack.
cdef np.ndarray pack_sim():
    cdef int i
    cdef np.ndarray pack = np.empty(5, dtype = np.int32)
    for i in range(5):
        pack[i] = rand() % 638
    return pack
# Simulate a single attempt to collect all the cards.
cpdef int single_sim_panini(np.ndarray single_card_collection):
    cdef int i, j
    cdef np.ndarray pack = np.empty(5, dtype = np.int32)
    for i in range(10000):
        pack = pack_sim()
        for j in range(5):
            single_card_collection[pack[j]] = 0
        if arr_sum(single_card_collection) == 0:
            break
    return i
# Simulate n sticker collection attempts.
cpdef np.ndarray many_sim_panini(int n):
    cdef int i
    record_of_packs_opened = np.zeros((n,), dtype = int)
    for i in range(n):
        collect_attempt = np.ones((638,), dtype = int)
        pack_attempt = single_sim_panini(collect_attempt)
        record_of_packs_opened[i] = pack_attempt
    return record_of_packs_opened
# Simulate n sticker collection attempts (cost).
cpdef np.ndarray many_sim_panini_cost(np.ndarray record_of_packs_opened):
    cdef int i
    cdef Py_ssize_t n = len(record_of_packs_opened)
    cdef double cost = 0.80
    record_of_cost = np.empty(n, dtype = np.double)
    for i in range(n):
        record_of_cost[i] = record_of_packs_opened[i] * cost
    return record_of_cost
# Main function of 10000 attempts
def main():
    cdef int N = 10000
    pack_data = many_sim_panini(N)
    cost_data = many_sim_panini_cost(pack_data)
    # Histograms of the data.
    plt.hist(pack_data, bins = 100)
    plt.hist(cost_data, bins = 100)
    plt.show()
    cdef double mu_pack, LQ_pack, sigma_pack, median_pack, UQ_pack, mu_cost, sigma_cost, LQ_cost, median_cost, UQ_cost
    # Statistical quantities (packs).
    mu_pack = np.mean(pack_data)
    sigma_pack = np.std(pack_data)
    LQ_pack = np.quantile(pack_data, 0.25)
    median_pack = np.median(pack_data)
    UQ_pack = np.quantile(pack_data, 0.75)
    # Statistical quantities (cost).
    mu_cost = np.mean(cost_data)
    sigma_cost = np.std(cost_data)
    LQ_cost = np.quantile(cost_data, 0.25)
    median_cost = np.median(cost_data)
    UQ_cost = np.quantile(cost_data, 0.75)
if __name__ == '__main__':
    main()
