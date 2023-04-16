import numpy as np
cimport numpy as np
import random
import matplotlib.pyplot as plt
import cython
from libc.stdlib cimport rand, srand
from libc.math cimport sqrt, pow
from libc.time cimport time
import time as T
srand(time(NULL))
# C function to sum all the elements.
cdef int arr_sum(int[::1] arr):
    cdef int i, total = 0
    cdef size_t n = len(arr)
    for i in range(n):
        total += arr[i]
    return total
# C function to simulate pack.
cdef int[::1] pack_sim():
    cdef int i
    cdef np.ndarray pack = np.zeros(5, dtype = np.intc)
    cdef int[::1] pack_view = pack
    for i in range(5):
        pack_view[i] = rand() % 638
    return pack_view
# Simulate a single attempt to collect all the cards.
cpdef int single_sim_panini(int[::1] single_card_collection):
    cdef int i, j
    cdef np.ndarray pack = np.empty(5, dtype = np.intc)
    cdef int[::1] pack_view
    for i in range(10000):
        pack_view = pack_sim()
        for j in range(5):
            single_card_collection[pack_view[j]] = 0
        if arr_sum(single_card_collection) == 0:
            break
    return i
# Simulate n sticker collection attempts.
cpdef int[::1] many_sim_panini(int n):
    cdef int i, pack_attempt
    cdef np.ndarray record_of_packs_opened = np.empty(n, dtype = np.intc)
    cdef np.ndarray collect_attempt
    cdef int[::1] ROPO_view = record_of_packs_opened
    cdef int[::1] collect_attempt_view
    for i in range(n):
        collect_attempt = np.ones((638,), dtype = np.intc)
        collect_attempt_view = collect_attempt
        pack_attempt = single_sim_panini(collect_attempt_view)
        ROPO_view[i] = pack_attempt
    return ROPO_view
# Simulate n sticker collection attempts (cost).
cpdef double[::1] many_sim_panini_cost(int[::1] record_of_packs_opened):
    cdef int i
    cdef Py_ssize_t n = len(record_of_packs_opened)
    cdef double cost = 0.80
    cdef np.ndarray record_of_cost = np.zeros(n, dtype = np.double)
    cdef double[::1] record_of_cost_view = record_of_cost 
    for i in range(n):
        record_of_cost_view[i] = record_of_packs_opened[i] * cost
    return record_of_cost_view
# Main function of 10000 attempts
def main():
    cdef int N = 10000
    start = T.time()
    pack_data = many_sim_panini(N)
    cost_data = many_sim_panini_cost(pack_data)
    end = T.time()
    print(end-start)
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
