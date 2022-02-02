#!/usr/bin/env python

from kmcos.types import Project, Condition, Action
import numpy as np


kmc_model = kmcos.create_kmc_model(model_name)



kmc_model.set_meta(author='StangenMensch',
            email='linie@tum.de',
            model_dimension=1,
            model_name='hopping_model')
kmc_model.add_species(name='empty',
               color='#ffffff',
               )
kmc_model.add_species(name='C',
               representation="Atoms('C',[[0,0,0]])",
               color='#000000')

kmc_model.layer_list.cell = np.diag([1., 1., 1.])
kmc_model.add_layer(name='default',
                     color='#ffffff')
kmc_model.add_site(layer='default',
            pos='0 0 0',
            name='a')

coord = kmc_model.layer_list.generate_coord

kmc_model.add_process(name='ads',
               rate_constant='10**6',
               conditions=[Condition(species='empty', coord=coord('a'))],
               actions=[Action(species='C', coord=coord('a'))],
               tof_count={'adsorption': 1})

kmc_model.add_process(name='des',
               rate_constant='10**6',
               conditions=[Condition(species='C', coord=coord('a'))],
               actions=[Action(species='empty', coord=coord('a'))],
               tof_count={'desorption': 1})

kmc_model.add_process(name='left',
               rate_constant='10**8',
               conditions=[Condition(species='C', coord=coord('a')),
                           Condition(species='empty', coord=coord('a.(-1, 0, 0)'))],
               actions=[Action(species='empty', coord=coord('a')),
                           Condition(species='C', coord=coord('a.(-1, 0, 0)'))],
               tof_count={'left': 1})

kmc_model.add_process(name='right',
               rate_constant='10**8',
               conditions=[Condition(species='C', coord=coord('a')),
                           Condition(species='empty', coord=coord('a.(1, 0, 0)'))],
               actions=[Action(species='empty', coord=coord('a')),
                           Condition(species='C', coord=coord('a.(1, 0, 0)'))],
               tof_count={'right': 1})

kmc_model.filename = 'einsD2.xml'
kmc_model.save()
