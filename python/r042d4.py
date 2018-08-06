import numpy as np
import nept

task_times = dict()
task_times['on_track'] = nept.Epoch(np.array([2577.8, 5004.3]))

experiment_times = dict()
experiment_times['left_trials'] = nept.Epoch(np.array([[2584.3, 2614.6],
                                                       [2734.8, 2758.9],
                                                       [2900.5, 2909.8],
                                                       [3023.9, 3030.7],
                                                       [3159.6, 3167.2],
                                                       [3300.8, 3307.4],
                                                       [3808.3, 3821.9],
                                                       [3940.4, 3947.8],
                                                       [4071.1, 4078.7],
                                                       [4402.5, 4432.3],
                                                       [4662.9, 4673.5]]))

experiment_times['right_trials'] = nept.Epoch(np.array([[3409.1, 3485.7],
                                                        [3589.9, 3606.7],
                                                        [3708.4, 3733.1],
                                                        [4226.6, 4328.2],
                                                        [4528.3, 4554.4],
                                                        [4799.2, 4836.0],
                                                        [4931.7, 4953.0]]))
