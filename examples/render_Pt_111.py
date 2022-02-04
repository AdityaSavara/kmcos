#!/usr/bin/env python
"""Just a short incomplete demo for a non-orthogonal surface

Note how the process editor cannot correctly display non-orthogonal lattices. (as of v0.3)

"""

from kmcos.types import *
from kmcos.io import *
import numpy as np


kmc_model = kmcos.create_kmc_model(model_name)
kmc_model.set_meta(author='Max J. Hoffmann',
            model_name='pt111',
            email='mjhoffmann@gmail.com',
            model_dimension=2,
            debug=0)


kmc_model.add_species(name='empty',
               color='#ffffff',)
kmc_model.add_species(name='H',
               representation="Atoms('H')",
               color='#ffff00')

layer = kmc_model.add_layer(name='pt111',)

kmc_model.lattice.representation = """[Atoms(symbols='Pt4',
          pbc=np.array([ True,  True, False], dtype=bool),
          cell=np.array(
      [[  2.77185858,   0.        ,   0.        ],
       [  1.38592929,   2.40049995,   0.        ],
       [  0.        ,   0.        ,  26.78963917]]),
          scaled_positions=np.array(
      [[0.0, 0.0, 0.37327863724326155], [0.33333333333333331, 0.33333333333333337, 0.45775954574775385], [0.66666666666666663, 0.66666666666666674, 0.54224045425224621], [0.0, 0.0, 0.62672136275673862]]),
),]"""

layer.sites.append(Site(name='hollow1', pos='0.333333333333 0.333333333333 0.672', default_species='default_species'))
layer.sites.append(Site(name='hollow2', pos='0.666666666667 0.666666666667 0.672', default_species='default_species'))

kmc_model.lattice.cell = np.array([[2.77185858, 0.0, 0.0],
                             [1.38592929, 2.40049995, 0.0],
                             [0.0, 0.0, 26.78963917]])

kmc_model.add_parameter(name='T', adjustable=True, min=300, max=800, value=600)

kmc_model.parse_and_add_process('H_adsorption_hollow1; empty@hollow1 -> H@hollow1; 100000')
kmc_model.parse_and_add_process('H_adsorption_hollow2; empty@hollow2 -> H@hollow2; 100000')

kmc_model.parse_and_add_process('H_desorption_hollow1; H@hollow1 -> empty@hollow1; 100000')
kmc_model.parse_and_add_process('H_desorption_hollow2; H@hollow2 -> empty@hollow2; 100000')


kmc_model.parse_and_add_process('H_diff_h1h2; H@hollow1 + empty@hollow2 -> empty@hollow1 + H@hollow2; 1000000000')
kmc_model.parse_and_add_process('H_diff_h2h1; H@hollow2 + empty@hollow1 -> empty@hollow2 + H@hollow1; 1000000000')

kmc_model.filename = 'Pt_111.xml'
kmc_model.save()
